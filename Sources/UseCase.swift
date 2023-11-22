import Foundation

public protocol UseCase {
    associatedtype Props: Equatable
    associatedtype Action

    typealias Middleware = (Props, Action) -> Effect<Self>

    var middleware: Middleware { get }
}
