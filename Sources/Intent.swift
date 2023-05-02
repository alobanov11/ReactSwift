import Foundation

public enum Intent<Feature: StoreSwift.Feature> {

    case action(Feature.Action)
    case feedback(Feature.Feedback)
}
