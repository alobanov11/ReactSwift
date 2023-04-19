//
//  Created by Антон Лобанов on 19.04.2023.
//

import Foundation

public enum Effect<Feedback, Output, Mutation> {
    public typealias Operation = (@Sendable @escaping (Feedback) async -> Void) async -> Void

    case none
    case output(Output)
    case run(Operation)
    case mutate(Mutation, Bool)
    indirect case combine([Effect])
}

public extension Effect {

    static func mutate(_ mutation: Mutation, trigger: Bool = true) -> Self {
        .mutate(mutation, trigger)
    }

    static func combine(_ effects: Effect...) -> Self {
        .combine(effects)
    }
}
