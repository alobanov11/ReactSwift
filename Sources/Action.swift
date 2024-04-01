import Foundation
import Combine

public struct Action<U: UseCase> {

    @dynamicMemberLookup
    public struct Props {

        public let get: () async -> U.Props
        public let set: (U.Props) async -> Void

        public func callAsFunction(_ newProps: (inout U.Props) -> Void) async {
            var props = await get()
            newProps(&props)
            await set(props)
        }

        public subscript<Value>(dynamicMember keyPath: KeyPath<U.Props, Value>) -> Value {
            get async { await get()[keyPath: keyPath] }
        }
    }

    let make: (Props, U) async -> Void

    public init(make: @escaping (Props, U) async -> Void) {
        self.make = make
    }
}
