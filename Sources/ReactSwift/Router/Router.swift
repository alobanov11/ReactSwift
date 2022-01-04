//
//  Created by Антон Лобанов on 04.01.2022.
//

import Foundation

open class Router<Module: IModule> {
	public typealias Input = Module.Input
	public typealias Output = Module.Output
	public typealias State = Module.State

	var _state: (() -> State)!
	var _invokeInput: ((Input) -> Void)!

	public init() {}

	open func handle(output: Output) {
		print("Must override in subclass")
	}

	@discardableResult
	public func invoke(input: Input) -> Self {
		self._invokeInput(input)
		return self
	}
}
