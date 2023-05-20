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
    private var context: Feature.Context
    
    private let outputSubject = PassthroughSubject<Feature.Output, Never>()
    private let stateSubject: CurrentValueSubject<Feature.State, Never>
    private let middleware: Feature.Middleware
    private let reducer: Feature.Reducer
    
    public init(
        state: Feature.State,
        context: Feature.Context,
        feedbacks: [AnyPublisher<Feature.Feedback, Never>] = [],
        middleware: @escaping Feature.Middleware,
        reducer: @escaping Feature.Reducer
    ) {
        self.stateSubject = .init(state)
        self.context = context
        self.middleware = middleware
        self.reducer = reducer
        self.cancellables.append(
            self.stateSubject.removeDuplicates().sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        )
        self.cancellables.append(contentsOf: feedbacks.map {
            $0.sink(receiveValue: { [weak self] in
                self?.print($0)
                self?.dispatch(.feedback($0))
            })
        })
    }
    
    deinit {
        for task in self.tasks {
            task.cancel()
        }
    }
}

extension Store {
    public func send(_ action: Feature.Action) {
        self.print(action)
        self.dispatch(.action(action))
    }

    public func update<T>(
        _ keyPath: WritableKeyPath<Feature.State, T>,
        newValue: T,
        by action: Feature.Action
    ) {
        self.state[keyPath: keyPath] = newValue
        self.send(action)
    }

    public func binding<T>(
        _ keyPath: WritableKeyPath<Feature.State, T>,
        by action: Feature.Action
    ) -> Binding<T> {
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

    public subscript<Value>(
        dynamicMember keyPath: KeyPath<Feature.State, Value>
    ) -> Value {
        self.state[keyPath: keyPath]
    }
}

private extension Store {
    func dispatch(_ intent: Feature.Intent) {
        let task = self.middleware(self.state, &self.context, intent)
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
                var ctx = self.context
                let task = await operation(&ctx)
                self.context = ctx
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
            self.print(output)
            self.outputSubject.send(output)
            
        case let .effect(effect):
            self.print(effect)
            self.reducer(&self.state, effect)

        case let .combine(events):
            for event in events {
                self.perform(event)
            }
        }
    }
    
    func print(_ value: Any) {
        let namespace = String(reflecting: Feature.self).components(separatedBy: ".").first
        LogHandler?(
            String(reflecting: value)
                .replacingOccurrences(of: namespace.map { $0 + "." } ?? "", with: "")
        )
    }
}
