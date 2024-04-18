import SwiftUI
import Combine

@MainActor
@dynamicMemberLookup
public final class Store<U: UseCase>: ObservableObject {

    @Published public private(set) var props: U.Props

    private let useCase: U?

    public init(_ initialProps: U.Props, useCase: U? = nil) {
        self.props = initialProps
        self.useCase = useCase
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<U.Props, Value>) -> Value {
        self.props[keyPath: keyPath]
    }
}

public extension Store {

    func send(_ action: Action<U>) {
        Task {
            await dispatch(action)
        }
    }

    func dispatch(_ action: Action<U>) async {
        guard let useCase else { return }
        let context = Action<U>.Context(
            get: { await MainActor.run { self.props } },
            set: { newValue in await MainActor.run { self.props = newValue } },
            useCase: useCase
        )
        await action.make(context)
    }

    func update<T>(
        _ keyPath: WritableKeyPath<U.Props, T>,
        newValue: T,
        by action: Action<U>
    ) {
        props[keyPath: keyPath] = newValue
        send(action)
    }

    func binding<T>(
        _ keyPath: WritableKeyPath<U.Props, T>,
        by action: Action<U>
    ) -> Binding<T> {
        Binding<T> {
            self.props[keyPath: keyPath]
        } set: { newValue in
            self.props[keyPath: keyPath] = newValue
            return self.send(action)
        }
    }

    func action(_ action: Action<U>) -> () -> Void {
        { self.send(action) }
    }
}
