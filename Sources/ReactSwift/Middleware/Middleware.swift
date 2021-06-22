//
//  Created by Антон Лобанов on 30.03.2021.
//

open class Middleware<Component: IComponent>
{
    public typealias Action = Component.Action
    public typealias Effect = Component.Effect
    public typealias Event = Component.Event
    public typealias State = Component.State

    public var state: State {
        _state()
    }

    var _state: (() -> State)!
    var _invokeEffect: ((Effect, Bool) -> Void)!
    var _invokeEvent: ((Event) -> Void)!
    var _throwError: ((Error) -> Void)!

    public init() {}

    open func handle(action: Action) {
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
    public func `throw`(_ error: Error) -> Self {
        self._throwError(error)
        return self
    }
}
