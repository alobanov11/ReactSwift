//
//  Created by Антон Лобанов on 25.03.2021.
//

import UIKit

public protocol Module {

    associatedtype State: Equatable
    associatedtype Action
    associatedtype Mutation
	associatedtype Feedback = Never
	associatedtype Output = Never
}
