import Foundation
import Combine

public enum EffectTask<Effect> {
    public typealias Operation = @Sendable () async -> Self
    public typealias Feedback = (Effect) -> Void

    case none
    case publisher((@escaping Feedback) -> AnyCancellable)
    case effects([Effect])
    case run(Operation)
    indirect case combine([Self])

    public static func effect(_ effects: Effect...) -> Self {
        .effects(effects)
    }

    public static func merge(_ tasks: Self...) -> Self {
        .combine(tasks)
    }
}
