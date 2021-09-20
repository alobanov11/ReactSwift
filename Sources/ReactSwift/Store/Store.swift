//
//  Created by Антон Лобанов on 25.03.2021.
//

import Foundation

public final class Store<Component: IComponent>
{
    public private(set) var state: Component.State {
        didSet {
            guard self.isObservingEnabled else { return }
            self.observers.forEach { $0(oldValue, self.state) }
        }
    }

    private var observers: [(Component.State?, Component.State) -> Void] = []
    private var catchers: [(Error) -> Void] = []
    private var listeners: [(Component.Event) -> Void] = []
    private var isObservingEnabled = true

    private let middleware: Middleware<Component>
    private let reducer: Reducer<Component>
    private let storage: Storage<Component.State>
    private let bios: ComponentBios<Component>?

    public init(
        middleware: Middleware<Component>,
        reducer: Reducer<Component>,
        initialState: Component.State,
        bios: ComponentBios<Component>? = nil
    ) {
        self.middleware = middleware
        self.reducer = reducer
        self.bios = bios
        self.state = initialState
        self.storage = .init(initialState)
        self.configure()
    }

    public func dispatch(_ action: Component.Action) {
        self.bios?.received(action: action)
        self.middleware.handle(action: action)
    }

    @discardableResult
    public func `catch`(_ closure: @escaping (Error) -> Void) -> Self {
		self.catchers.append(closure)
        return self
    }

    @discardableResult
    public func listen(_ closure: @escaping (Component.Event) -> Void) -> Self {
		self.listeners.append(closure)
        return self
    }
}

// MARK: - Observe state

public extension Store {
    @discardableResult
    func observe(_ closure: @escaping (Component.State) -> Void) -> Self {
        self.addObservation { _, new in
            closure(new)
        }
    }

    @discardableResult
    func observe<T: Equatable>(_ keyPath: KeyPath<Component.State, T>, closure: @escaping (T) -> Void) -> Self {
        self.addObservation { old, new in
            let oldValue = old?[keyPath: keyPath]
            let newValue = new[keyPath: keyPath]
            guard newValue != oldValue else { return }
            closure(newValue)
        }
    }

    @discardableResult
    func observe(
        _ sourceKeyPaths: [PartialKeyPath<Component.State>],
        handler: @escaping (Component.State) -> Void
    ) -> Self {
        self.addObservation { old, new in
            var haveChanges = false
            sourceKeyPaths.forEach { keyPath in
                let oldValue = old?[keyPath: keyPath] as? AnyHashable
                let newValue = new[keyPath: keyPath] as? AnyHashable
                guard oldValue != newValue else { return }
                haveChanges = true
            }
            guard haveChanges else { return }
            handler(new)
        }
        return self
    }

    @discardableResult
    func bind<Object: AnyObject, T: Equatable>(
        _ keyPath: KeyPath<Component.State, T>,
        to object: Object,
        _ objectKeyPath: ReferenceWritableKeyPath<Object, T>
    ) -> Self {
        self.addObservation { [weak object] old, new in
            let oldValue = old?[keyPath: keyPath]
            let newValue = new[keyPath: keyPath]
            guard newValue != oldValue else { return }
            object?[keyPath: objectKeyPath] = newValue
        }
    }

    @discardableResult
    func bind<Object: AnyObject, T: Equatable>(
        _ keyPath: KeyPath<Component.State, T>,
        to object: Object,
        _ objectKeyPath: ReferenceWritableKeyPath<Object, Optional<T>>
    ) -> Self {
        self.addObservation { [weak object] old, new in
            let oldValue = old?[keyPath: keyPath]
            let newValue = new[keyPath: keyPath]
            guard newValue != oldValue else { return }
            object?[keyPath: objectKeyPath] = newValue
        }
    }

    @discardableResult
    func bind<Object: AnyObject, T, V: Equatable>(
        _ keyPath: KeyPath<Component.State, V>,
        to object: Object,
        _ objectKeyPath: ReferenceWritableKeyPath<Object, T>,
        map: @escaping (V) -> T
    ) -> Self {
        self.addObservation { [weak object] old, new in
            guard let object = object else { return }
            let oldValue = old?[keyPath: keyPath]
            let newValue = new[keyPath: keyPath]
            guard newValue != oldValue else { return }
            object[keyPath: objectKeyPath] = map(newValue)
        }
    }

    @discardableResult
    func bind<Object: AnyObject, T, V: Equatable>(
        _ keyPath: KeyPath<Component.State, Optional<V>>,
        to object: Object,
        _ objectKeyPath: ReferenceWritableKeyPath<Object, T>,
        map: @escaping (V?) -> T
    ) -> Self {
        self.addObservation { [weak object] old, new in
            guard let object = object else { return }
            let oldValue = old?[keyPath: keyPath]
            let newValue = new[keyPath: keyPath]
            guard newValue != oldValue else { return }
            object[keyPath: objectKeyPath] = map(newValue)
        }
    }
}

// MARK: - Private

private extension Store {
    func configure() {
		let initialState = self.state

        self.middleware._state = { [weak self] in
			guard let self = self else { return initialState }
			return self.state
		}

        self.middleware._throwError = { [weak self] err in
			guard let self = self else { return }
            self.bios?.throwed(err)
			self.catchers.forEach { $0(err) }
        }

        self.middleware._invokeEvent = { [weak self] event in
			guard let self = self else { return }
            self.bios?.invoked(event: event)
			self.listeners.forEach { $0(event) }
        }

        self.middleware._invokeEffect = { [weak self] effect, trigger in
			guard let self = self else { return }
            self.bios?.invoked(effect: effect)
            self.storage.mutate {
                self.isObservingEnabled = trigger
                $0 = self.reducer.reduce(state: $0, effect: effect)
            }
        }

        self.storage.subscribe(self) {
            $0.state = $2
            $0.isObservingEnabled = true
        }
    }

    @discardableResult
    private func addObservation(_ closure: @escaping (Component.State?, Component.State) -> Void) -> Self {
        closure(nil, self.state)
        self.observers.append { old, new in
            DispatchQueue.main.async { closure(old, new) }
        }
        return self
    }
}
