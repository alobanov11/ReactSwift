import UIKit

public protocol Feature {

    associatedtype Action
    associatedtype Effect
    associatedtype Enviroment
	associatedtype Output = Never
    associatedtype State: Equatable
}
