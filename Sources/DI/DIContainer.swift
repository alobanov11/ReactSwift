import Foundation

public final class DIContainer {
    public static var global = DIContainer()

    private var storage: [ObjectIdentifier: Any] = [:]

    public init() {}

    public subscript<Key: DIKey>(key: Key.Type) -> Key.Value {
        get {
            return (storage[ObjectIdentifier(key)] as? Key.Value) ?? Key.defaultValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}
