import Foundation

@propertyWrapper
public struct Dependency<Value> {
    public var keyPath: WritableKeyPath<DIContainer, Value>

    public init(keyPath: WritableKeyPath<DIContainer, Value>) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        get {
            DIContainer.global[keyPath: keyPath]
        }
        set {
            DIContainer.global[keyPath: keyPath] = newValue
        }
    }
}
