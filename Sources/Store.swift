//
//  Created by Антон Лобанов on 09.04.2022.
//

import Foundation

open class Store<M: Module>: ViewStore<M> {

    public typealias Module = M
    public typealias State = M.State
	public typealias Action = M.Action
    public typealias Feedback = M.Feedback
    public typealias Mutation = M.Mutation
	public typealias Output = M.Output
    public typealias Effect = StoreSwift.Effect<Feedback, Output, Mutation>

    private var tasks: [Task<Void, Never>] = []

    deinit {
        for task in self.tasks {
            task.cancel()
        }
    }

    public override func send(_ action: Action) {
        let task = Task { await self.dispatch(.action(action)) }
        self.tasks.append(task)
    }

    open func transform(_ intent: Intent<Action, Feedback>) -> Effect {
        print("Override in subclass")
        return .none
    }

	open class func mutate(_ state: inout State, mutation: Mutation) {
		print("Override in subclass")
	}
}

private extension Store {

    func dispatch(_ intent: Intent<Action, Feedback>) async {
        guard Task.isCancelled == false else { return }
        let effect = self.transform(intent)
        await self.apply(effect)
    }

    func apply(_ effect: Effect) async {
        switch effect {
        case .none:
            break

        case let .output(output):
            self.outputSubject.send(output)

        case let .run(operation):
            await operation { [weak self] feedback in
                guard !Task.isCancelled else { return }
                await self?.dispatch(.feedback(feedback))
            }

        case let .mutate(mutation, trigger):
            self.needsToCallObservers = trigger
            Self.mutate(&self.state, mutation: mutation)

        case let .combine(effects):
            for effect in effects {
                await self.apply(effect)
            }
        }
    }
}
