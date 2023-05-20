import UIKit

public protocol Feature {
    associatedtype State: Equatable
    associatedtype Action
    associatedtype Effect
    associatedtype Context
    associatedtype Feedback = Never
    associatedtype Output = Never
    
    typealias EffectTask = StoreSwift.EffectTask<Effect, Output, Context>
    typealias Intent = StoreSwift.Intent<Action, Feedback>
    
    typealias Middleware = (State, inout Context, Intent) -> EffectTask
    typealias Reducer = (inout State, Effect) -> Void
}
