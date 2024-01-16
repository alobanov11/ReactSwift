import SwiftUI
import Combine

@MainActor
@dynamicMemberLookup
public final class Store<U: UseCase>: ObservableObject {
    @Published public private(set) var props: U.Props

    private var cancellables: [AnyHashable: AnyCancellable] = [:]
    
    private let middleware: U.Middleware

    public init(_ initialProps: U.Props, useCase: U? = nil) {
        self.props = initialProps
        self.middleware = useCase?.middleware ?? { _, _ in .none }
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<U.Props, Value>) -> Value {
        self.props[keyPath: keyPath]
    }
}

extension Store {
    public func send(_ action: U.Action) {
        let task = self.middleware(self.props, action)
        self.perform(task)
    }

    public func dispatch(_ action: U.Action) async {
        let task = self.middleware(self.props, action)
        await self.asyncPerform(task)
    }

    public func update<T>(
        _ keyPath: WritableKeyPath<U.Props, T>,
        newValue: T,
        by action: U.Action
    ) {
        self.props[keyPath: keyPath] = newValue
        self.send(action)
    }

    public func binding<T>(
        _ keyPath: WritableKeyPath<U.Props, T>,
        by action: U.Action
    ) -> Binding<T> {
        Binding<T> {
            return self.props[keyPath: keyPath]
        } set: { newValue in
            self.props[keyPath: keyPath] = newValue
            return self.send(action)
        }
    }

    public func action(_ action: U.Action) -> () -> Void {
        { self.send(action) }
    }
}

private extension Store {
    func perform(_ task: Effect<U>) {
        for operation in task.operations {
            switch operation {
            case .none:
                continue

            case let .publisher(id, publisher):
                self.cancellables[id] = publisher({ [weak self] in self?.props })?
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] task in self?.perform(task) }

            case let .mutate(mutation):
                mutation(&self.props)

            case let .run(operation):
                Task {
                    let task = await operation()
                    self.perform(task)
                }
            }
        }
    }

    func asyncPerform(_ task: Effect<U>) async {
        for operation in task.operations {
            switch operation {
            case .none:
                continue

            case let .publisher(id, publisher):
                self.cancellables[id] = publisher({ [weak self] in self?.props })?
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] task in self?.perform(task) }

            case let .mutate(mutation):
                mutation(&self.props)

            case let .run(operation):
                let task = await operation()
                await asyncPerform(task)
            }
        }
    }
}
