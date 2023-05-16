import Foundation

public enum Intent<Action, Feedback> {
    case action(Action)
    case feedback(Feedback)
}
