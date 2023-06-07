import UIKit

public protocol UseCase {
    associatedtype State: Equatable
    associatedtype Action
    associatedtype Effect = Never

    static var actionReducer: Reducer<Action, Self> { get }
    static var effectReducer: Reducer<Effect, Self> { get }
}

public typealias Reducer<Event, UseCaseType: UseCase> = (
    _: Event,
    _: inout UseCaseType.State,
    _: inout UseCaseType
) -> EffectTask<UseCaseType.Effect>

public extension UseCase {
    static var effectReducer: Reducer<Effect, Self> {
        { _, _, _ in .none }
    }
}
