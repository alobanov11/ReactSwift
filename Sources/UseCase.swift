import UIKit

public typealias Reducer<Event, State, Effect, Object> = (
    _: Event,
    _: inout State,
    _: inout Object
) -> EffectTask<Effect>

public protocol UseCase {
    associatedtype State: Equatable
    associatedtype Action
    associatedtype Effect = Never

    typealias ActionReducer = Reducer<Action, State, Effect, Self>
    typealias EffectReducer = Reducer<Effect, State, Effect, Self>

    static var actionReducer: ActionReducer { get }
    static var effectReducer: EffectReducer { get }
}



public extension UseCase {
    static var effectReducer: EffectReducer {
        { _, _, _ in .none }
    }
}
