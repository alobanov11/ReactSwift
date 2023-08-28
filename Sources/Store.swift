import SwiftUI
import Combine

@MainActor
@dynamicMemberLookup
public final class Store<U: UseCase>: ObservableObject {
    @Published public private(set) var state: U.State

    private var cancellables: [AnyHashable: AnyCancellable] = [:]

    private let reducer: U.Reducer
    private let middleware: U.Middleware

    public init<T: UseCase>(
        _ initialState: U.State,
        useCase: T
    ) where T.State == U.State, T.Action == U.Action, T.Effect == U.Effect {
        self.state = initialState
        self.reducer = useCase.reducer
        self.middleware = useCase.middleware
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

        case let .publisher(id, cancellable):
            self.cancellables[id] = cancellable { [weak self] effect in
                self?.perform(effect)
            }

        case let .multiple(effects):
            for effect in effects {
                self.reducer(&self.state, effect)
            }

        case let .run(operation):
            Task {
                await self.perform(operation())
            }

        case let .combine(tasks):
            for task in tasks {
                self.perform(task)
            }
        }
    }
}
