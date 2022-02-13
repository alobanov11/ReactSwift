//
//  Created by Антон Лобанов on 12.02.2022.
//

import Foundation

public struct StoreLog<Module: IModule>: Hashable
{
	public var actions: [Module.Action]
	public var effects: [Module.Effect]
	public var events: [Module.Event]
	public var inputs: [Module.Input]
	public var outputs: [Module.Output]
	public var errors: [String]

	public init(
		actions: [Module.Action] = [],
		effects: [Module.Effect] = [],
		events: [Module.Event] = [],
		inputs: [Module.Input] = [],
		outputs: [Module.Output] = [],
		errors: [String] = []
	) {
		self.actions = actions
		self.effects = effects
		self.events = events
		self.inputs = inputs
		self.outputs = outputs
		self.errors = errors
	}
}
