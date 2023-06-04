import SwiftUI
import Combine

@MainActor
@dynamicMemberLookup
public final class Store<UseCaseType: UseCase>: ObservableObject {
    public var state: UseCaseType.State {
        set {
            guard newValue != self.state else { return }
            self.objectWillChange.send()
            self.subject.send(newValue)
        }
        get {
            return self.subject.value
        }
    }

    public var publisher: AnyPublisher<UseCaseType.State, Never> {
        self.subject.eraseToAnyPublisher()
    }

    private var useCase: UseCaseType
    private var tasks: [Task<Void, Never>] = []
    private var cancellables: Set<AnyCancellable> = []

    private let subject: CurrentValueSubject<UseCaseType.State, Never>

    public init(
        useCase: UseCaseType,
        state: UseCaseType.State,
        feedbacks: [AnyPublisher<UseCaseType.Effect, Never>] = []
    ) {
        self.useCase = useCase
        self.subject = CurrentValueSubject(state)
        feedbacks.forEach {
            self.cancellables.insert($0.sink { [weak self] in
                self?.perform(.effect($0))
            })
        }
    }

    deinit {
        for task in self.tasks {
            task.cancel()
        }
    }

    public subscript<Value>(
        dynamicMember keyPath: KeyPath<UseCaseType.State, Value>
    ) -> Value {
        self.state[keyPath: keyPath]
    }
}

extension Store {
    public func send(_ action: UseCaseType.Action) {
        let task = UseCaseType.actionReducer(action, &self.state, &self.useCase)
        self.perform(task)
    }

    public func update<T>(
        _ keyPath: WritableKeyPath<UseCaseType.State, T>,
        newValue: T,
        by action: UseCaseType.Action
    ) {
        self.state[keyPath: keyPath] = newValue
        self.send(action)
    }

    public func binding<T>(
        _ keyPath: WritableKeyPath<UseCaseType.State, T>,
        by action: UseCaseType.Action
    ) -> Binding<T> {
        Binding<T> {
            return self.state[keyPath: keyPath]
        } set: { newValue in
            self.state[keyPath: keyPath] = newValue
            return self.send(action)
        }
    }

    public func action(_ action: UseCaseType.Action) -> () -> Void {
        { self.send(action) }
    }
}

private extension Store {
    func perform(_ task: EffectTask<UseCaseType.Effect>) {
        switch task {
        case .none:
            break

        case let .effect(effect):
            self.perform(UseCaseType.effectReducer(effect, &self.state, &self.useCase))

        case let .run(operation):
            self.tasks.append(Task {
                guard Task.isCancelled == false else { return }
                await self.perform(operation())
            })

        case let .combine(tasks):
            for task in tasks {
                self.perform(task)
            }
        }
    }
}
