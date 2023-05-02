import Foundation

public enum EffectTask<Feature: StoreSwift.Feature> {

    public enum Event {

        case output(Feature.Output)
        case effect(Feature.Effect)

        indirect case combine([Event])
    }

    public typealias Operation = (inout Feature.Enviroment) async -> EffectTask

    case none
    case event(Event)
    case run(Operation)

    indirect case combine([EffectTask])
}

public extension EffectTask {

    static func output(_ output: Feature.Output) -> EffectTask {
        .event(.output(output))
    }

    static func effect(_ effect: Feature.Effect) -> EffectTask {
        .event(.effect(effect))
    }

    static func combine(_ effects: EffectTask...) -> Self {
        .combine(effects)
    }

    func unwrap(_ env: inout Feature.Enviroment) async -> [Event] {
        switch self {
        case .none:
            return []

        case let .event(event):
            return [event]

        case let .run(operation):
            let effect = await operation(&env)
            let events = await effect.unwrap(&env)
            return events

        case let .combine(effects):
            var events: [Event] = []
            for effect in effects {
                let subEvents = await effect.unwrap(&env)
                events.append(contentsOf: subEvents)
            }
            return events
        }
    }
}

extension EffectTask.Event: Equatable where Feature.Output: Equatable, Feature.Effect: Equatable {}
