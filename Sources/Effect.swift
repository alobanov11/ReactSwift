import Foundation
import Combine

public struct Effect<U: UseCase> {
    enum Operation {
        case none
        case publisher(AnyHashable, (@escaping () -> U.Props?) -> AnyPublisher<Effect<U>, Never>?)
        case mutate((inout U.Props) -> Void)
        case run(@Sendable () async -> Effect<U>)
    }

    let operations: [Operation]

    init(operations: [Operation]) {
        self.operations = operations
    }
}

extension Effect {
    public static var none: Self {
        Self(operations: [.none])
    }

    public static func publisher(
        _ id: AnyHashable = UUID(),
        _ createPublisher: @autoclosure @escaping () -> AnyPublisher<Self, Never>?
    ) -> Self {
        Self(operations: [
            .publisher(id) { _ in
                createPublisher()
            }
        ])
    }

    public static func publisher<T>(
        _ id: AnyHashable = UUID(),
        createPublisher: @escaping () -> AnyPublisher<T, Never>,
        sink handler: @escaping (T, U.Props) -> Self
    ) -> Self {
        Self(operations: [
            .publisher(id) { state in
                createPublisher()
                    .map { value in state().map { handler(value, $0) } ?? .none }
                    .eraseToAnyPublisher()
            }
        ])
    }

    public static func mutate(_ operation: @escaping (inout U.Props) -> Void) -> Self {
        Self(operations: [.mutate(operation)])
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

    public static func merge(_ tasks: Self...) -> Self {
        Self(operations: tasks.flatMap { $0.operations })
    }

    public static func merge(_ tasks: [Self]) -> Self {
        Self(operations: tasks.flatMap { $0.operations })
    }
}
