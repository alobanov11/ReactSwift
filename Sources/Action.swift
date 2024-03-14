import Foundation
import Combine

public struct Action<U: UseCase> {

    public struct Context {

        public let get: () async -> U.Props
        public let set: (U.Props) async -> Void
        public let useCase: U

        public func getProps<Value>(_ keyPath: KeyPath<U.Props, Value>) async -> Value {
            await get()[keyPath: keyPath]
        }

        public func setProps<Value>(_ keyPath: WritableKeyPath<U.Props, Value>, _ newValue: Value) async {
            var props = await get()
            props[keyPath: keyPath] = newValue
            await set(props)
        }

        public func setProps(_ newProps: (inout U.Props) -> Void) async {
            var props = await get()
            newProps(&props)
            await set(props)
        }
    }

    let make: (Context) async -> Void

    public init(make: @escaping (Context) -> Void) {
        self.make = make
    }
}
