import SwiftUI
import Combine

@MainActor
@dynamicMemberLookup
public final class Store<U: UseCase>: ObservableObject {
    @Published public private(set) var state: U.State

    private var cancellables: [AnyHashable: AnyCancellable] = [:]
    
    private let middleware: U.Middleware

    public init(_ initialState: U.State, useCase: U? = nil) {
        self.state = initialState
        self.middleware = useCase?.middleware ?? { _, _ in .none }
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<U.State, Value>) -> Value {
        self.state[keyPath: keyPath]
    }
}

extension Store {
    public func send(_ action: U.Action) {
        Task {
            await self.dispatch(action)
        }
    }

    public func dispatch(_ action: U.Action) async {
        let task = self.middleware(self.state, action)
        await self.perform(task)
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
    func perform(_ task: EffectTask<U>) async {
        for operation in task.operations {
            switch operation {
            case .none:
                break

            case let .publisher(id, publisher):
                self.cancellables[id] = publisher({ [weak self] in self?.state })?
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] task in Task { await self?.perform(task) } }

            case let .mutate(mutation):
                mutation(&self.state)

            case let .run(operation):
                await self.perform(operation())
            }
        }
    }
}
