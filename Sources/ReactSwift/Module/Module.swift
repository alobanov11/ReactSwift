//
//  Created by Антон Лобанов on 25.03.2021.
//

import UIKit

public struct EmptyModuleItem: Hashable {
	public init() {}
}

public protocol IModule {
    associatedtype Action
    associatedtype Effect
    associatedtype Event = EmptyModuleItem
	associatedtype Input = EmptyModuleItem
	associatedtype Output = EmptyModuleItem
    associatedtype State: Hashable
}
