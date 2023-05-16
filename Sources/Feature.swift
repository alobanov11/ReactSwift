import UIKit

public protocol Feature {
    associatedtype Action
    associatedtype Effect
    associatedtype Enviroment
    associatedtype Feedback = Never
	associatedtype Output = Never
    associatedtype State: Equatable

    typealias EffectTask = StoreSwift.EffectTask<Effect, Output, Enviroment>
    typealias Intent = StoreSwift.Intent<Action, Feedback>

    typealias Reduce = (State, inout Enviroment, Intent) -> EffectTask
    typealias Mutate = (inout State, Effect) -> Void
}
