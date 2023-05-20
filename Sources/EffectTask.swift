import Foundation

public enum EffectTask<Effect, Output, Context> {
    public enum Event {
        case output(Output)
        case effect(Effect)
        
        indirect case combine([Event])
    }
    
    public typealias Operation = (inout Context) async -> EffectTask
    
    case none
    case event(Event)
    case run(Operation)
    
    indirect case combine([EffectTask])
}

public extension EffectTask {
    static func output(_ output: Output...) -> EffectTask {
        .event(.combine(output.map { .output($0) }))
    }
    
    static func effect(_ effect: Effect...) -> EffectTask {
        .event(.combine(effect.map { .effect($0) }))
    }
    
    static func combine(_ effects: EffectTask...) -> Self {
        .combine(effects)
    }
}

extension EffectTask.Event: Equatable where Output: Equatable, Effect: Equatable {}
