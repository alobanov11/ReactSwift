import Foundation

public protocol UseCase {
    associatedtype State: Equatable
    associatedtype Action

    typealias Middleware = (State, Action) -> EffectTask<Self>

    var middleware: Middleware { get }
}
