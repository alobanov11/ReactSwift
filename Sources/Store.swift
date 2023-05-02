//
//  Created by Антон Лобанов on 25.03.2021.
//

import Combine
import SwiftUI

@MainActor
@dynamicMemberLookup
public final class Store<Feature: StoreSwift.Feature>: ObservableObject {

    public typealias Middleware = (_: Feature.State, _: inout Feature.Enviroment, _: Feature.Action) -> EffectTask<Feature>
    public typealias Reducer = (_: inout Feature.State, _: Feature.Effect) -> Void

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
    private var enviroment: Feature.Enviroment

	private let outputSubject = PassthroughSubject<Feature.Output, Never>()
    private let middleware: Middleware
    private let reducer: Reducer

    public init(
        initialState: Feature.State,
        enviroment: Feature.Enviroment,
        middleware: @escaping Middleware,
        reducer: @escaping Reducer
    ) {
		self.state = initialState
        self.enviroment = enviroment
        self.middleware = middleware
        self.reducer = reducer
	}

    deinit {
        for task in self.tasks {
            task.cancel()
        }
    }

	public func send(_ action: Feature.Action) {
        let task = self.middleware(self.state, &self.enviroment, action)
        self.perform(task)
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

    func perform(_ task: EffectTask<Feature>) {
        switch task {
        case .none:
            break

        case let .intent(intent):
            self.perform(intent)

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

    func perform(_ intent: EffectTask<Feature>.Intent) {
        switch intent {
        case let .output(output):
            self.outputSubject.send(output)

        case let .effect(effect):
            self.reducer(&self.state, effect)

        case let .combine(intents):
            for intent in intents {
                self.perform(intent)
            }
        }
    }
}
