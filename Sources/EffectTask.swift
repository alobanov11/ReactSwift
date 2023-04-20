//
//  Created by Антон Лобанов on 19.04.2023.
//

import Foundation

public enum EffectTask<Feedback, Output, Effect> {
    public typealias Operation = (@Sendable @escaping (Feedback) async -> Void) async throws -> Void

    case none
    case error(Error)
    case output(Output)
    case run(Operation)
    case effect(Effect, Bool)
    indirect case combine([EffectTask])
}

public extension EffectTask {

    static func effect(_ effect: Effect, trigger: Bool = true) -> Self {
        .effect(effect, trigger)
    }

    static func combine(_ effects: EffectTask...) -> Self {
        .combine(effects)
    }
}
