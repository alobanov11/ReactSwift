import Foundation
import Combine

public struct Action<U: UseCase> {

    @dynamicMemberLookup
    public struct Context {

        public let get: () async -> U.Props
        public let set: (U.Props) async -> Void
        public let useCase: U

        public func callAsFunction(_ newProps: (inout U.Props) -> Void) async {
            await set(newProps)
        }

        public func set(_ newProps: (inout U.Props) -> Void) async {
            var props = await get()
            newProps(&props)
            await set(props)
        }

        public subscript<Value>(dynamicMember keyPath: KeyPath<U, Value>) -> Value {
            useCase[keyPath: keyPath]
        }

        public subscript<Value>(dynamicMember keyPath: KeyPath<U.Props, Value>) -> Value {
            get async { await get()[keyPath: keyPath] }
        }
    }

    public let make: (Context) async -> Void

    public init(make: @escaping (Context) async -> Void) {
        self.make = make
    }

    public init(make: @escaping () async -> Void) {
        self.make = { _ in await make() }
    }
}
