import UIKit

public protocol Feature {

    associatedtype Action
    associatedtype Effect
    associatedtype Enviroment
    associatedtype Feedback = Never
	associatedtype Output = Never
    associatedtype State: Equatable

    typealias Middleware = (_: State, _: inout Enviroment, _: Intent<Self>) -> EffectTask<Self>
    typealias Reducer = (_: inout State, _: Effect) -> Void
}
