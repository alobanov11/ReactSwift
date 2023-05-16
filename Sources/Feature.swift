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

    typealias Middleware = (_: State, _: inout Enviroment, _: Intent) -> EffectTask
    typealias Reducer = (_: inout State, _: Effect) -> Void
}
