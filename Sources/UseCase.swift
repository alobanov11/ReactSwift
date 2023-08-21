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

public struct EmptyUseCase<U: UseCase>: UseCase {
    public typealias State = U.State
    public typealias Action = U.Action
    public typealias Effect = U.Effect

    public let reducer: Reducer
    public let middleware: Middleware

    public init() {
        self.reducer = { _, _ in }
        self.middleware = { _, _ in .none }
    }
}
