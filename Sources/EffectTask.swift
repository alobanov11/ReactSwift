import Foundation
import Combine

public enum EffectTask<U: UseCase> {
    case none
    case publisher(AnyHashable, (U, @escaping () -> U.State) -> AnyPublisher<Self, Never>)
    case effects([U.Effect])
    case run(@Sendable (U) async -> Self)
    case runAndForget(@Sendable (U) async -> Void)
    indirect case combine([Self])

    public static func effect(_ effects: U.Effect...) -> Self {
        .effects(effects)
    }

    public static func merge(_ tasks: Self...) -> Self {
        .combine(tasks)
    }
}
