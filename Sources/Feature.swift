import UIKit

public protocol Feature {

    associatedtype Action
    associatedtype Effect
    associatedtype Enviroment
    associatedtype Feedback = Never
	associatedtype Output = Never
    associatedtype State: Equatable
}
