//
//  Created by Антон Лобанов on 09.04.2022.
//

import Foundation

open class Store<Module: IModule>: ViewStore<Module> {
	public typealias Action = Module.Action
	public typealias Event = Module.Event
	public typealias State = Module.State

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

	public func mutate(_ closure: (inout State) -> Void, trigger: Bool = true) -> Self {
		self.storage.mutate {
			self.isObservingEnabled = trigger
			closure(&$0)
		}
		return self
	}
}
