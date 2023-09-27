import SwiftUI
import Combine

@MainActor
@dynamicMemberLookup
public final class Store<U: UseCase>: ObservableObject {
    @Published public private(set) var state: U.State

    private var useCase: U?
    private var cancellables: [AnyHashable: AnyCancellable] = [:]

    private let reduce: U.Reducer
    private let middleware: U.Middleware

    public init(_ initialState: U.State, useCase: U? = nil) {
        self.state = initialState
        self.useCase = useCase
        self.reduce = U.reduce
        self.middleware = U.middleware
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<U.State, Value>) -> Value {
        self.state[keyPath: keyPath]
    }
}

extension Store {
    public func send(_ action: U.Action) {
        guard let useCase = self.useCase else { return }
        let task = self.middleware(useCase, self.state, action)
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
    func perform(_ task: EffectTask<U>) {
        switch task {
        case .none:
            break

        case let .publisher(id, publisher):
            self.cancellables[id] = publisher({ self.state })
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.perform($0) }

        case let .effects(effects):
            for effect in effects {
                self.reduce(&self.state, effect)
            }

        case let .run(operation):
            Task {
                await self.perform(operation())
            }

        case let .runAndForget(operation):
            Task {
                await operation()
            }

        case let .combine(tasks):
            for task in tasks {
                self.perform(task)
            }
        }
    }
}
