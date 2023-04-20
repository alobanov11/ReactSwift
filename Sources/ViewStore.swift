//
//  Created by Антон Лобанов on 25.03.2021.
//

import Combine
import Foundation

@MainActor
@dynamicMemberLookup
open class ViewStore<M: Module>: ObservableObject {

    public internal(set) var state: M.State {
		willSet {
			self.objectWillChange.send()
			if self.needsToCallObservers {
				self.observers.forEach { $0(self.state, newValue) }
                self.needsToCallObservers = false
			}
		}
	}

	public var output: AnyPublisher<M.Output, Never> {
		self.outputSubject.eraseToAnyPublisher()
	}

    public var error: AnyPublisher<Error, Never> {
        self.errorSubject.eraseToAnyPublisher()
    }

	var needsToCallObservers = true

	let outputSubject = PassthroughSubject<M.Output, Never>()
    let errorSubject = PassthroughSubject<Error, Never>()

	private var observers: [(M.State?, M.State) -> Void] = []
	private var cancellables: [AnyCancellable] = []

    public init(initialState: M.State) {
		self.state = initialState
	}

	public func send(_ action: M.Action) {
		print("Must override in subclass")
	}

	@discardableResult
	public func listen(_ closure: @escaping (M.Output) -> Void) -> Self {
        self.outputSubject.sink(receiveValue: closure).store(in: &self.cancellables)
        return self
	}

    public subscript<Value>(dynamicMember keyPath: KeyPath<M.State, Value>) -> Value {
      self.state[keyPath: keyPath]
    }

	@discardableResult
	func addObservation(_ closure: @escaping (M.State?, M.State) -> Void) -> Self {
		closure(nil, self.state)
		self.observers.append(closure)
		return self
	}
}
