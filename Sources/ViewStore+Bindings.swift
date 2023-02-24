//
//  Created by Антон Лобанов on 14.01.2023.
//

import SwiftUI
import Foundation

public extension ViewStore {
	func binding<T>(_ keyPath: WritableKeyPath<M.State, T>, by action: M.Action) -> Binding<T> {
		Binding<T> {
			return self.state[keyPath: keyPath]
		} set: { newValue in
			self.state[keyPath: keyPath] = newValue
			return self.dispatch(action)
		}
	}

	func action(_ action: M.Action) -> () -> Void {
		{ self.dispatch(action) }
	}
}

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
