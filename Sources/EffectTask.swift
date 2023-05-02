import Foundation

public enum EffectTask<Feature: StoreSwift.Feature> {

    public enum Intent {

        case output(Feature.Output)
        case effect(Feature.Effect)

        indirect case combine([Intent])
    }

    public typealias Operation = (inout Feature.Enviroment) async -> EffectTask

    case none
    case intent(Intent)
    case run(Operation)

    indirect case combine([EffectTask])
}

public extension EffectTask {

    static func output(_ output: Feature.Output) -> EffectTask {
        .intent(.output(output))
    }

    static func effect(_ effect: Feature.Effect) -> EffectTask {
        .intent(.effect(effect))
    }

    static func combine(_ effects: EffectTask...) -> Self {
        .combine(effects)
    }

    func unwrap(_ env: inout Feature.Enviroment) async -> [Intent] {
        switch self {
        case .none:
            return []

        case let .intent(intent):
            return [intent]

        case let .run(operation):
            let effect = await operation(&env)
            let intents = await effect.unwrap(&env)
            return intents

        case let .combine(effects):
            var intents: [Intent] = []
            for effect in effects {
                let subIntents = await effect.unwrap(&env)
                intents.append(contentsOf: subIntents)
            }
            return intents
        }
    }
}

extension EffectTask.Intent: Equatable where Feature.Output: Equatable, Feature.Effect: Equatable {}
