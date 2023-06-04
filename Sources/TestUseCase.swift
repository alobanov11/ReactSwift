import Foundation

public final class TestStore<UseCaseType: UseCase> {
    public enum Event {
        case action(UseCaseType.Action)
        case effect(UseCaseType.Effect)
    }

    public enum TestError: LocalizedError {
        case fieldEqual(Int, Any)
        case fieldIsNotEqual(Int, Any)
        case effectsIsNotEqual([UseCaseType.Effect])
        case noEffects

        public var errorDescription: String? {
            switch self {
            case let .fieldEqual(line, value):
                return "Value on line \(line) \(value) is the same before event"
            case let .fieldIsNotEqual(line, value):
                return "Value on line \(line) \(value) is not the same after event"
            case let .effectsIsNotEqual(effects):
                return "Effects is not equal to \(String(reflecting: effects))"
            case .noEffects:
                return "No effects to apply"
            }
        }
    }

    private var useCase: UseCaseType
    private var state: UseCaseType.State
    private var effects: [UseCaseType.Effect] = []

    private var initialUseCase: UseCaseType
    private var initialState: UseCaseType.State

    public init(
        _ event: Event,
        useCase: UseCaseType,
        state: UseCaseType.State
    ) async {
        self.initialUseCase = useCase
        self.initialState = state
        self.useCase = useCase
        self.state = state
        switch event {
        case let .action(action):
            self.effects = await UseCaseType.actionReducer(action, &self.state, &self.useCase).unzip()
        case let .effect(effect):
            self.effects = await UseCaseType.effectReducer(effect, &self.state, &self.useCase).unzip()
        }
    }

    @discardableResult
    public func assert<Value: Equatable>(
        _ keyPath: KeyPath<UseCaseType.State, Value>,
        _ value: Value,
        _ line: Int = #line
    ) throws -> Self {
        if self.initialState[keyPath: keyPath] == value {
            throw TestError.fieldEqual(line, value)
        }
        if self.state[keyPath: keyPath] != value {
            throw TestError.fieldIsNotEqual(line, value)
        }
        return self
    }

    @discardableResult
    public func assert<Value: Equatable>(
        _ keyPath: KeyPath<UseCaseType.State, Optional<Value>>,
        _ value: Value?,
        _ line: Int = #line
    ) throws -> Self {
        if self.initialState[keyPath: keyPath] == value {
            throw TestError.fieldEqual(line, value)
        }
        if self.state[keyPath: keyPath] != value {
            throw TestError.fieldIsNotEqual(line, value)
        }
        return self
    }

    @discardableResult
    public func assert<Value: Equatable>(
        _ keyPath: KeyPath<UseCaseType, Value>,
        _ value: Value,
        _ line: Int = #line
    ) throws -> Self {
        if self.initialUseCase[keyPath: keyPath] == value {
            throw TestError.fieldEqual(line, value)
        }
        if self.useCase[keyPath: keyPath] != value {
            throw TestError.fieldIsNotEqual(line, value)
        }
        return self
    }

    @discardableResult
    public func assert<Value: Equatable>(
        _ keyPath: KeyPath<UseCaseType, Optional<Value>>,
        _ value: Value?,
        _ line: Int = #line
    ) throws -> Self {
        if self.initialUseCase[keyPath: keyPath] == value {
            throw TestError.fieldEqual(line, value)
        }
        if self.useCase[keyPath: keyPath] != value {
            throw TestError.fieldIsNotEqual(line, value)
        }
        return self
    }

    @discardableResult
    public func assert(
        _ effects: [UseCaseType.Effect],
        _ line: Int = #line
    ) throws -> Self where UseCaseType.Effect: Equatable {
        if effects != self.effects {
            throw TestError.effectsIsNotEqual(self.effects)
        }
        return self
    }

    @discardableResult
    public func apply() async throws -> Self {
        guard !self.effects.isEmpty else {
            throw TestError.noEffects
        }
        var effects = self.effects
        self.initialUseCase = self.useCase
        self.initialState = self.state
        self.effects = []
        for effect in effects {
            await self.effects.append(contentsOf: UseCaseType.effectReducer(effect, &self.state, &self.useCase).unzip())
        }
        return self
    }
}
