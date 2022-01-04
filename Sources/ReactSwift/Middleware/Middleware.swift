//
//  Created by Антон Лобанов on 30.03.2021.
//

open class Middleware<Module: IModule> {
    public typealias Action = Module.Action
    public typealias Effect = Module.Effect
    public typealias Event = Module.Event
	public typealias Input = Module.Input
	public typealias Output = Module.Output
    public typealias State = Module.State

    public var state: State {
        _state()
    }

    var _state: (() -> State)!
    var _invokeEffect: ((Effect, Bool) -> Void)!
    var _invokeEvent: ((Event) -> Void)!
	var _invokeOutput: ((Output) -> Void)!
    var _throwError: ((Error) -> Void)!

    public init() {}

    open func handle(action: Action) {
        print("Must override in subclass")
    }

	open func handle(input: Input) {
		print("Must override in subclass")
	}

    @discardableResult
    public func invoke(effect: Effect, trigger: Bool = true) -> Self {
        self._invokeEffect(effect, trigger)
        return self
    }

    @discardableResult
    public func invoke(event: Event) -> Self {
        self._invokeEvent(event)
        return self
    }

	@discardableResult
	public func invoke(output: Output) -> Self {
		self._invokeOutput(output)
		return self
	}

    @discardableResult
    public func `throw`(_ error: Error) -> Self {
        self._throwError(error)
        return self
    }
}
