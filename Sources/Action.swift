import Foundation
import Combine

public struct Action<U: UseCase> {

    @dynamicMemberLookup
    public struct Context {

        public var props: U.Props {
            get async {
                await get()
            }
        }

        let get: () async -> U.Props
        let set: (U.Props) async -> Void
        let useCase: U

        public func callAsFunction(_ newProps: (inout U.Props) -> Void) async {
            var props = await get()
            newProps(&props)
            await set(props)
        }

        public subscript<Value>(dynamicMember keyPath: KeyPath<U, Value>) -> Value {
            useCase[keyPath: keyPath]
        }
    }

    let make: (Context) async -> Void

    public init(make: @escaping (Context) async -> Void) {
        self.make = make
    }

    public init(make: @escaping () async -> Void) {
        self.make = { _ in await make() }
    }

    public func callAsFunction(_ context: Context) async {
        await make(context)
    }
}
