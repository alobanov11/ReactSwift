//
//  Created by Антон Лобанов on 09.04.2022.
//

import Foundation

open class Store<M: Module>: ViewStore<M> {
	public typealias Module = M
	public typealias Action = M.Action
	public typealias Effect = M.Effect
	public typealias Event = M.Event
	public typealias State = M.State

	open class func reduce(_ state: inout State, effect: Effect) {
		print("Override in subclass")
	}

	@discardableResult
	public func invoke(effect: Effect, trigger: Bool = true) -> Self {
		self.storage.mutate {
			self.isObservingEnabled = trigger
			Self.reduce(&$0, effect: effect)
		}
		return self
	}

	@discardableResult
	public func invoke(event: Event) -> Self {
		self.listeners.forEach { $0(event) }
		return self
	}

	@discardableResult
	public func `throw`(_ error: Error) -> Self {
		self.catchers.forEach { $0(.error(error)) }
		return self
	}

	@discardableResult
	public func `throw`(_ error: String) -> Self {
		self.catchers.forEach { $0(.text(error)) }
		return self
	}
}
