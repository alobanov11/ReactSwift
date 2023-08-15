import Foundation

public protocol UseCase {
    associatedtype State: Equatable
    associatedtype Action
    associatedtype Effect

    typealias Reducer = (inout State, Effect) -> Void
    typealias Middleware = (State, Action) -> EffectTask<Effect>

    var reducer: Reducer { get }
    var middleware: Middleware { get }
}
