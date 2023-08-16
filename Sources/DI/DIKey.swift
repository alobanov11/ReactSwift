import Foundation

public protocol DIKey {
    associatedtype Value

    static var defaultValue: Value { get }
}

public extension DIKey {
    var liveValue: Value {
        get { DIContainer.global[Self.self] }
        set { DIContainer.global[Self.self] = newValue }
    }
}
