//
//  Created by Антон Лобанов on 09.04.2022.
//

import Foundation

open class Store<Module: IModule>: ViewStore<Module> {
	public typealias Action = Module.Action
	public typealias Effect = Module.Effect
	public typealias Event = Module.Event
	public typealias State = Module.State

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
		self.catchers.forEach { $0(error) }
		return self
	}
}
