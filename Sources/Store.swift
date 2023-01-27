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

	open class func reduce(_ state: inout State, effect: Effect) throws {
		print("Override in subclass")
	}

	@discardableResult
	public func invoke(effect: Effect, trigger: Bool = true) -> Self {
		self.log(["Call effect:", effect, "trigger: \(trigger)"])
		self.needsToCallObservers = trigger
		do {
			try Self.reduce(&self.state, effect: effect)
		}
		catch {
			self.throw(error)
		}
		self.needsToCallObservers = true
		return self
	}

	@discardableResult
	public func invoke(event: Event) -> Self {
		self.log(["Call event:", event])
		self._event.send(event)
		return self
	}

	@discardableResult
	public func `throw`(_ error: Error) -> Self {
		self.log(["Throw error:", error])
		self._error.send(.error(error))
		return self
	}

	@discardableResult
	public func `throw`(_ error: String) -> Self {
		self.log(["Throw error:", error])
		self._error.send(.text(error))
		return self
	}

	private func log(
		_ values: [Any?],
		_ file: StaticString = #file,
		_ function: StaticString = #function,
		_ line: UInt = #line
	) {
		StoreLogger.log(values, file, function, line)
	}
}
