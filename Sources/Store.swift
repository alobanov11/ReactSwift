//
//  Created by Антон Лобанов on 25.03.2021.
//

import Combine
import SwiftUI

@MainActor
@dynamicMemberLookup
public final class Store<Feature: StoreSwift.Feature>: ObservableObject {

    public internal(set) var state: Feature.State {
		willSet {
            if self.state != newValue {
                self.objectWillChange.send()
            }
		}
	}

    public var output: AnyPublisher<Feature.Output, Never> {
		self.outputSubject.eraseToAnyPublisher()
	}

    private var tasks: [Task<Void, Never>] = []
    private var cancellables: [AnyCancellable] = []
    private var enviroment: Feature.Enviroment

	private let outputSubject = PassthroughSubject<Feature.Output, Never>()
    private let middleware: Feature.Middleware
    private let reducer: Feature.Reducer

    public init(
        initialState: Feature.State,
        enviroment: Feature.Enviroment,
        feedbacks: [AnyPublisher<Feature.Feedback, Never>] = [],
        middleware: @escaping Feature.Middleware,
        reducer: @escaping Feature.Reducer
    ) {
		self.state = initialState
        self.enviroment = enviroment
        self.middleware = middleware
        self.reducer = reducer
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

    func dispatch(_ intent: Intent<Feature>) {
        let task = self.middleware(self.state, &self.enviroment, intent)
        self.log(intent)
        self.perform(task)
    }

    func perform(_ task: EffectTask<Feature>) {
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

    func perform(_ event: EffectTask<Feature>.Event) {
        switch event {
        case let .output(output):
            self.log(output)
            self.outputSubject.send(output)

        case let .effect(effect):
            self.log(effect)
            self.reducer(&self.state, effect)

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
