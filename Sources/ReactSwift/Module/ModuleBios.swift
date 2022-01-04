//
//  Created by Антон Лобанов on 05.04.2021.
//

import Foundation

open class ModuleBios<Module: IModule>
{
    public typealias Action = Module.Action
    public typealias Effect = Module.Effect
    public typealias Event = Module.Event
    public typealias State = Module.State
	public typealias Input = Module.Input
	public typealias Output = Module.Output

    public init() {}

    open func received(action: Action) {}

    open func invoked(effect: Effect) {}

    open func invoked(event: Event) {}

	open func invoked(input: Input) {}

	open func invoked(output: Output) {}

    open func throwed(_ error: Error) {}
}
