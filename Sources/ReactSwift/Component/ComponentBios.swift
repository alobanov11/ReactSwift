//
//  Created by Антон Лобанов on 05.04.2021.
//

import Foundation

open class ComponentBios<Component: IComponent>
{
    public typealias Action = Component.Action
    public typealias Effect = Component.Effect
    public typealias Event = Component.Event
    public typealias State = Component.State

    public init() {}

    open func received(action: Action) {}

    open func invoked(effect: Effect) {}

    open func invoked(event: Event) {}

    open func throwed(_ error: Error) {}
}
