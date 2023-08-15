import Foundation
import Combine

public enum EffectTask<Effect> {
    public typealias Operation = @Sendable () async -> Self
    public typealias Feedback = (Self) -> Void

    case none
    case publisher((@escaping Feedback) -> AnyCancellable)
    case effect(Effect)
    case run(Operation)
    indirect case combine([Self])

    public static func merge(_ tasks: Self...) -> Self {
        .combine(tasks)
    }
}
