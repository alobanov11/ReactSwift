import Foundation

public protocol UseCase {
    associatedtype State: Equatable
    associatedtype Action
    associatedtype Effect

    typealias Reducer = (inout State, Effect) -> Void
    typealias Middleware = (State, Action) -> EffectTask<Self>

    static var reduce: Reducer { get }
    var middleware: Middleware { get }
}
