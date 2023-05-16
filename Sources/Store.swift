import Combine
import SwiftUI

@MainActor
@dynamicMemberLookup
public final class Store<Feature: StoreSwift.Feature>: ObservableObject {
    public var state: AnyPublisher<Feature.State, Never> {
        self.stateSubject.eraseToAnyPublisher()
	}

    public var currentState: Feature.State {
        self.stateSubject.value
    }

    public var output: AnyPublisher<Feature.Output, Never> {
		self.outputSubject.eraseToAnyPublisher()
	}

    private var tasks: [Task<Void, Never>] = []
    private var cancellables: [AnyCancellable] = []
    private var enviroment: Feature.Enviroment

	private let outputSubject = PassthroughSubject<Feature.Output, Never>()
    private let stateSubject: CurrentValueSubject<Feature.State, Never>
    private let middleware: Feature.Middleware
    private let reducer: Feature.Reducer

    public init(
        _ state: Feature.State,
        enviroment: Feature.Enviroment,
        feedbacks: [AnyPublisher<Feature.Feedback, Never>] = [],
        middleware: @escaping Feature.Middleware,
        reducer: @escaping Feature.Reducer
    ) {
        self.stateSubject = .init(state)
        self.enviroment = enviroment
        self.middleware = middleware
        self.reducer = reducer
        self.cancellables.append(
            self.stateSubject.removeDuplicates().sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        )
        self.cancellables.append(contentsOf: feedbacks.map {
            $0.sink(receiveValue: { [weak self] in self?.dispatch(.feedback($0)) })
        })
	}

    deinit {
        for task in self.tasks {
            task.cancel()
        }
    }

	public func send(_ action: Feature.Action) {
        self.dispatch(.action(action))
	}

    public func update<T>(_ keyPath: WritableKeyPath<Feature.State, T>, newValue: T, by action: Feature.Action) {
        var state = self.currentState
        state[keyPath: keyPath] = newValue
        self.stateSubject.send(state)
        self.send(action)
    }

    public func binding<T>(_ keyPath: WritableKeyPath<Feature.State, T>, by action: Feature.Action) -> Binding<T> {
        Binding<T> {
            return self.currentState[keyPath: keyPath]
        } set: { newValue in
            var state = self.currentState
            state[keyPath: keyPath] = newValue
            self.stateSubject.send(state)
            return self.send(action)
        }
    }

    public func action(_ action: Feature.Action) -> () -> Void {
        { self.send(action) }
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<Feature.State, Value>) -> Value {
        self.currentState[keyPath: keyPath]
    }
}

private extension Store {
    func dispatch(_ intent: Feature.Intent) {
        let task = self.middleware(self.currentState, &self.enviroment, intent)
        self.log(intent)
        self.perform(task)
    }

    func perform(_ task: Feature.EffectTask) {
        switch task {
        case .none:
            break

        case let .event(event):
            self.perform(event)

        case let .run(operation):
            self.tasks.append(Task {
                guard Task.isCancelled == false else { return }
                var env = self.enviroment
                let task = await operation(&env)
                self.enviroment = env
                self.perform(task)
            })

        case let .combine(tasks):
            for task in tasks {
                self.perform(task)
            }
        }
    }

    func perform(_ event: Feature.EffectTask.Event) {
        switch event {
        case let .output(output):
            self.log(output)
            self.outputSubject.send(output)

        case let .effect(effect):
            var state = self.currentState
            self.reducer(&state, effect)
            self.stateSubject.send(state)
            self.log(effect)

        case let .combine(events):
            for event in events {
                self.perform(event)
            }
        }
    }

    func log(_ value: Any) {
        LogHandler?(value, String(describing: Feature.self))
    }
}
