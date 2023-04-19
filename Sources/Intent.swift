//
//  Created by Антон Лобанов on 19.04.2023.
//

import Foundation

public enum Intent<Action, Feedback>: Sendable where Action: Sendable, Feedback: Sendable {

    case action(Action)
    case feedback(Feedback)
}
