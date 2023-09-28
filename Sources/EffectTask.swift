import Foundation
import Combine

public struct EffectTask<U: UseCase> {
    enum Operation {
        case none
        case publisher(AnyHashable, (@escaping () -> U.State?) -> AnyPublisher<EffectTask<U>, Never>?)
        case effects([U.Effect])
        case run(@Sendable () async -> EffectTask<U>)
    }

    let operations: [Operation]

    init(operations: [Operation]) {
        self.operations = operations
    }
}

extension EffectTask {
    public static var none: Self {
        Self(operations: [.none])
    }

    public static func publisher(
        _ id: AnyHashable = UUID(),
        createPublisher: @autoclosure @escaping () -> AnyPublisher<Self, Never>?
    ) -> Self {
        Self(operations: [
            .publisher(id) { _ in
                createPublisher()
            }
        ])
    }

    public static func publisher<T>(
        _ id: AnyHashable = UUID(),
        createPublisher: @autoclosure @escaping () -> AnyPublisher<T, Never>,
        sink handler: @escaping (T, U.State) -> Self
    ) -> Self {
        Self(operations: [
            .publisher(id) { state in
                createPublisher()
                    .map { value in state().map { handler(value, $0) } ?? .none }
                    .eraseToAnyPublisher()
            }
        ])
    }

    public static func effect(_ effects: U.Effect...) -> Self {
        Self(operations: [.effects(effects)])
    }

    public static func effects(_ effects: [U.Effect]) -> Self {
        Self(operations: [.effects(effects)])
    }

    public static func run(
        operation: @escaping @Sendable () async throws -> Self,
        catch handler: (@Sendable (_ error: Error) async -> Self)? = nil
    ) -> Self {
        Self(operations: [
            .run {
                do {
                    return try await operation()
                }
                catch {
                    if let handler {
                        return await handler(error)
                    }
                    return .none
                }
            }
        ])
    }

    public static func runAndForget(
        operation: @escaping @Sendable () async -> Void
    ) -> Self {
        Self(operations: [
            .run {
                await operation()
                return .none
            }
        ])
    }
}
