import SwiftUI
import Combine

@MainActor
@dynamicMemberLookup
public final class Store<U: UseCase>: ObservableObject {
    @Published public private(set) var state: U.State

    private var cancellables: [AnyHashable: AnyCancellable] = [:]
    
    private let reduce: U.Reducer
    private let middleware: U.Middleware

    public init(_ initialState: U.State, useCase: U? = nil) {
        self.state = initialState
        self.reduce = U.reduce
        self.middleware = useCase?.middleware ?? { _, _ in .none }
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
    func perform(_ task: EffectTask<U>) {
        task.operations.forEach {
            switch $0 {
            case .none:
                break

            case let .publisher(id, publisher):
                self.cancellables[id] = publisher({ [weak self] in self?.state })?
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in self?.perform($0) }

            case let .effects(effects):
                for effect in effects {
                    U.reduce(&self.state, effect)
                }

            case let .run(operation):
                Task {
                    await self.perform(operation())
                }
            }
        }
    }
}
