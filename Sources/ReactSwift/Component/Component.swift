//
//  Created by Антон Лобанов on 25.03.2021.
//

public enum NoEvent {}

public protocol IComponent
{
    associatedtype Action
    associatedtype Effect
    associatedtype Event = NoEvent
    associatedtype State: Hashable
}
