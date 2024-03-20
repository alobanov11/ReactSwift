import Foundation
import Combine

public struct Action<U: UseCase> {

    @dynamicMemberLookup
    public struct Context {

        public let get: () async -> U.Props
        public let set: (U.Props) async -> Void
        public let useCase: U

        public func set<Value>(_ keyPath: WritableKeyPath<U.Props, Value>, _ newValue: Value) async {
            var props = await get()
            props[keyPath: keyPath] = newValue
            await set(props)
        }

        public func set(_ newProps: (inout U.Props) -> Void) async {
            var props = await get()
            newProps(&props)
            await set(props)
        }

        public subscript<Value>(dynamicMember keyPath: KeyPath<U.Props, Value>) -> Value {
            get async { await get()[keyPath: keyPath] }
        }
    }

    let make: (Context) async -> Void

    public init(make: @escaping (Context) async -> Void) {
        self.make = make
    }
}
