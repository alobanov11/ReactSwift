import Foundation
import Combine

public enum EffectTask<U: UseCase> {
    case none
    case publisher(AnyHashable, (@escaping () -> U.State) -> AnyPublisher<Self, Never>)
    case effects([U.Effect])
    case run(@Sendable () async -> Self)
    case runAndForget(@Sendable () async -> Void)
    indirect case combine([Self])

    public static func effect(_ effects: U.Effect...) -> Self {
        .effects(effects)
    }

    public static func merge(_ tasks: Self...) -> Self {
        .combine(tasks)
    }
}
