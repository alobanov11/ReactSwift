//
//  Created by Антон Лобанов on 09.04.2022.
//

import Foundation

open class Store<M: Module>: ViewStore<M> {

    public typealias Module = M
	public typealias Action = M.Action
    public typealias Effect = M.Effect
    public typealias Feedback = M.Feedback
	public typealias Output = M.Output
    public typealias State = M.State

    public typealias Intent = StoreSwift.Intent<Action, Feedback>
    public typealias EffectTask = StoreSwift.EffectTask<Feedback, Output, Effect>

    private var tasks: [Task<Void, Never>] = []

    deinit {
        for task in self.tasks {
            task.cancel()
        }
    }

    open func transform(_ intent: Intent) -> EffectTask {
        print("Override in subclass")
        return .none
    }

    open class func reduce(_ state: inout State, effect: Effect) throws {
        print("Override in subclass")
    }

    public override func send(_ action: Action) {
        self.dispatch(.action(action))
    }

    public func send(_ feedback: Feedback) {
        self.dispatch(.feedback(feedback))
    }
}

private extension Store {

    func dispatch(_ intent: Intent) {
        self.tasks.append(Task {
            guard Task.isCancelled == false else { return }
            let effectTask = self.transform(intent)
            do {
                try await self.perform(effectTask)
            }
            catch {
                self.dispatch(.error(intent, error))
            }
        })
    }

    func perform(_ effectTask: EffectTask) async throws {
        switch effectTask {
        case .none:
            break

        case let .error(error):
            self.errorSubject.send(error)

        case let .output(output):
            self.outputSubject.send(output)

        case let .run(operation):
            try await operation { [weak self] feedback in
                guard Task.isCancelled == false else { return }
                await self?.dispatch(.feedback(feedback))
            }

        case let .effect(effect, trigger):
            self.needsToCallObservers = trigger
            try Self.reduce(&self.state, effect: effect)

        case let .combine(effects):
            for effect in effects {
                try await self.perform(effect)
            }
        }
    }
}
