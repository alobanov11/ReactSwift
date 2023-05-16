import Combine
import SwiftUI

@MainActor
@dynamicMemberLookup
public final class Store<Feature>: ObservableObject where Feature: StoreSwift.Feature {
    public internal(set) var state: Feature.State {
        get { self.stateSubject.value }
        set { self.stateSubject.send(newValue) }
	}

    public var currentState: AnyPublisher<Feature.State, Never> {
        self.stateSubject.eraseToAnyPublisher()
    }

    public var output: AnyPublisher<Feature.Output, Never> {
		self.outputSubject.eraseToAnyPublisher()
	}

    private var tasks: [Task<Void, Never>] = []
    private var cancellables: [AnyCancellable] = []
    private var enviroment: Feature.Enviroment?

	private let outputSubject = PassthroughSubject<Feature.Output, Never>()
    private let stateSubject: CurrentValueSubject<Feature.State, Never>
    private let reduce: Feature.Reduce
    private let mutate: Feature.Mutate

    public init(
        _ state: Feature.State,
        enviroment: Feature.Enviroment? = nil,
        feedbacks: [AnyPublisher<Feature.Feedback, Never>] = [],
        reduce: @escaping Feature.Reduce = { _, _, _ in .none },
        mutate: @escaping Feature.Mutate = { _, _ in }
    ) {
        self.stateSubject = .init(state)
        self.enviroment = enviroment
        self.reduce = reduce
        self.mutate = mutate
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
        self.state[keyPath: keyPath] = newValue
        self.send(action)
    }

    public func binding<T>(_ keyPath: WritableKeyPath<Feature.State, T>, by action: Feature.Action) -> Binding<T> {
        Binding<T> {
            return self.state[keyPath: keyPath]
        } set: { newValue in
            self.state[keyPath: keyPath] = newValue
            return self.send(action)
        }
    }

    public func action(_ action: Feature.Action) -> () -> Void {
        { self.send(action) }
    }

    public subscript<Value>(dynamicMember keyPath: KeyPath<Feature.State, Value>) -> Value {
        self.state[keyPath: keyPath]
    }
}

private extension Store {
    func dispatch(_ intent: Feature.Intent) {
        guard var env = self.enviroment else { return }
        let task = self.reduce(self.state, &env, intent)
        self.enviroment = env
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
                guard Task.isCancelled == false, var env = self.enviroment else { return }
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
            self.mutate(&state, effect)
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
