import Foundation

public enum EffectTask<Effect> {
    public typealias Operation = @Sendable () async -> Self

    case none
    case effect(Effect)
    case run(Operation)
    indirect case combine([Self])

    public static func zip(_ tasks: Self...) -> Self {
        .combine(tasks)
    }

    public func unzip() async -> [Effect] {
        switch self {
        case .none:
            return []

        case let .effect(effect):
            return [effect]

        case let .run(operation):
            let task = await operation()
            return await task.unzip()

        case let .combine(tasks):
            var effects: [Effect] = []
            for task in tasks {
                await effects.append(contentsOf: task.unzip())
            }
            return effects
        }
    }
}
