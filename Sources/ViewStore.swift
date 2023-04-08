//
//  Created by Антон Лобанов on 25.03.2021.
//

import Combine
import Foundation

@MainActor
open class ViewStore<M: Module>: ObservableObject {
	public internal(set) var state: M.State {
		willSet {
			self.objectWillChange.send()
			if self.needsToCallObservers {
				self.observers.forEach { $0(self.state, newValue) }
			}
		}
	}

	public var error: AnyPublisher<StoreError, Never> {
		self._error.eraseToAnyPublisher()
	}

	public var event: AnyPublisher<M.Event, Never> {
		self._event.eraseToAnyPublisher()
	}

	var needsToCallObservers = true

	let _error = PassthroughSubject<StoreError, Never>()
	let _event = PassthroughSubject<M.Event, Never>()

	private var observers: [(M.State?, M.State) -> Void] = []
	private var cancellables: [AnyCancellable] = []

	nonisolated public init(initialState: M.State) {
		self.state = initialState
	}

	open func dispatch(_ action: M.Action) {
        log([action])
		print("Must override in subclass")
	}

	@discardableResult
	public func `catch`(_ closure: @escaping (StoreError) -> Void) -> Self {
		self.store(self._error.sink(receiveValue: closure))
	}

	@discardableResult
	public func listen(_ closure: @escaping (M.Event) -> Void) -> Self {
		self.store(self._event.sink(receiveValue: closure))
	}

	@discardableResult
	public func store(_ cancellable: AnyCancellable) -> Self {
		self.cancellables.append(cancellable)
		return self
	}

	@discardableResult
	func addObservation(_ closure: @escaping (M.State?, M.State) -> Void) -> Self {
		closure(nil, self.state)
		self.observers.append(closure)
		return self
	}

    func log(_ values: [Any?]) {
        StoreLogger.log(values, String(describing: M.self))
    }
}
