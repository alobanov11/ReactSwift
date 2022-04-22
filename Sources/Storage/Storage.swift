//
//  Created by Антон Лобанов on 25.03.2021.
//

import Foundation

final class Storage<Value: Equatable> {
	private(set) var value: Value {
		didSet {
			self.subscribers = self.subscribers.filter { $0(oldValue, self.value) }
		}
	}
	
	private var subscribers: [(Value, Value) -> Bool] = []
	private let mutex = DispatchQueue(label: "com.reactswift.Storage", attributes: .concurrent)
	
	init(_ value: Value) {
		self.value = value
	}
	
	func subscribe<T: AnyObject>(_ object: T, closure: @escaping (T, Value, Value) -> Void) {
		self.subscribers.append { [weak object] old, new in
			guard let object = object else { return false }
			guard new != old else { return true }
			closure(object, old, new)
			return true
		}
	}
	
	func mutate(_ closure: (inout Value) -> Void) {
		self.mutex.sync(flags: .barrier) {
			closure(&self.value)
		}
	}
}
