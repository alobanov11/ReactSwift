//
//  Created by Антон Лобанов on 25.03.2021.
//

import UIKit

public protocol Module {

    associatedtype Action
    associatedtype Effect
	associatedtype Feedback = Never
	associatedtype Output = Never
    associatedtype State: Equatable
}
