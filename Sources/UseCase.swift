import UIKit

public protocol UseCase {
    associatedtype State: Equatable
    associatedtype Action
    associatedtype Effect = Never

    typealias ActionReducer = (_: Action, _: inout State, _: inout Self) -> EffectTask<Effect>
    typealias EffectReducer = (_: Effect, _: inout State, _: inout Self) -> EffectTask<Effect>

    static var actionReducer: ActionReducer { get }
    static var effectReducer: EffectReducer { get }
}

public extension UseCase {
    static var effectReducer: EffectReducer {
        { _, _, _ in .none }
    }
}
