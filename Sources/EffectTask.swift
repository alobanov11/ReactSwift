import Foundation

public enum EffectTask<Effect> {
    public typealias Operation = @Sendable () async -> Self

    case none
    case effect(Effect)
    case run(Operation)
    indirect case combine([Self])

    public static func merge(_ tasks: Self...) -> Self {
        .combine(tasks)
    }
}
