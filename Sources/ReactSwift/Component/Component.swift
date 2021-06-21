//
//  Created by Антон Лобанов on 25.03.2021.
//

// MARK: - IComponent

public protocol IComponent
{
    associatedtype Action
    associatedtype Effect
    associatedtype State: Hashable
}
