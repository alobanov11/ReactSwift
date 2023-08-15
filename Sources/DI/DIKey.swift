import Foundation

public protocol DIKey {
    associatedtype Value

    static var defaultValue: Value { get }
}
