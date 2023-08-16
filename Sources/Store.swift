import SwiftUI
import Combine

@dynamicMemberLookup
public final class Store<U: UseCase>: ObservableObject {
    @Published public private(set) var state: U.State

    private var tasks: [Task<Void, Never>] = []
    private var cancellables: Set<AnyCancellable> = []

    private let reducer: U.Reducer
    private let middleware: U.Middleware

    public init(
        _ initialState: U.State,
        useCase: U
    ) {
        self.state = initialState
        self.reducer = useCase.reducer
        self.middleware = useCase.middleware
    }

    deinit {
        for task in self.tasks {
            task.cancel()
        }
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<U.State, Value>) -> Value {
        self.state[keyPath: keyPath]
    }
}

extension Store {
    public func send(_ action: U.Action) {
        let task = self.middleware(self.state, action)
        self.perform(task)
    }

    public func update<T>(
        _ keyPath: WritableKeyPath<U.State, T>,
        newValue: T,
        by action: U.Action
    ) {
        self.state[keyPath: keyPath] = newValue
        self.send(action)
    }

    public func binding<T>(
        _ keyPath: WritableKeyPath<U.State, T>,
        by action: U.Action
    ) -> Binding<T> {
        Binding<T> {
            return self.state[keyPath: keyPath]
        } set: { newValue in
            self.state[keyPath: keyPath] = newValue
            return self.send(action)
        }
    }

    public func action(_ action: U.Action) -> () -> Void {
        { self.send(action) }
    }
}

private extension Store {
    func perform(_ task: EffectTask<U.Effect>) {
        switch task {
        case .none:
            break

        case let .publisher(cancellable):
            self.cancellables.insert(cancellable { [weak self] effect in
                self?.perform(.effect(effect))
            })

        case let .effect(effect):
            self.reducer(&self.state, effect)

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
