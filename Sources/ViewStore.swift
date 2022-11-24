//
//  Created by Антон Лобанов on 25.03.2021.
//

import Foundation

open class ViewStore<M: Module> {
	public private(set) var state: M.State {
		didSet {
			guard self.isObservingEnabled else { return }
			self.observers.forEach { $0(oldValue, self.state) }
		}
	}

	var observers: [(M.State?, M.State) -> Void] = []
	var catchers: [(StoreError) -> Void] = []
	var listeners: [(M.Event) -> Void] = []
	var isObservingEnabled = true

	let storage: Storage<M.State>

	public init(initialState: M.State) {
		self.state = initialState
		self.storage = .init(initialState)

		self.storage.subscribe(self) {
			$0.state = $2
			$0.isObservingEnabled = true
		}
	}

	open func dispatch(_ action: M.Action) {
		print("Must override in subclass")
	}

	@discardableResult
	public func `catch`(_ closure: @escaping (StoreError) -> Void) -> Self {
		self.catchers.append(closure)
		return self
	}

	@discardableResult
	public func listen(_ closure: @escaping (M.Event) -> Void) -> Self {
		self.listeners.append(closure)
		return self
	}
}

// MARK: - Observe state

public extension ViewStore {
	@discardableResult
	func observe(_ closure: @escaping (M.State) -> Void) -> Self {
		self.addObservation { _, new in
			closure(new)
		}
	}

	@discardableResult
	func observe<T: Equatable>(_ keyPath: KeyPath<M.State, T>, closure: @escaping (T) -> Void) -> Self {
		self.addObservation { old, new in
			let oldValue = old?[keyPath: keyPath]
			let newValue = new[keyPath: keyPath]
			guard newValue != oldValue else { return }
			closure(newValue)
		}
	}

	@discardableResult
	func observe(
		_ sourceKeyPaths: [PartialKeyPath<M.State>],
		handler: @escaping (M.State) -> Void
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
		_ keyPath: KeyPath<M.State, T>,
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
		_ keyPath: KeyPath<M.State, T>,
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
		_ keyPath: KeyPath<M.State, V>,
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
		_ keyPath: KeyPath<M.State, Optional<V>>,
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

private extension ViewStore {
	@discardableResult
	private func addObservation(_ closure: @escaping (M.State?, M.State) -> Void) -> Self {
		closure(nil, self.state)
		self.observers.append { old, new in
			DispatchQueue.main.async { closure(old, new) }
		}
		return self
	}
}
