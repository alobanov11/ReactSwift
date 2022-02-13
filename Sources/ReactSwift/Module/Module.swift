//
//  Created by Антон Лобанов on 25.03.2021.
//

import UIKit

public struct EmptyModuleItem: Hashable {
	public init() {}
}

public protocol IModule {
	associatedtype Action: Hashable
    associatedtype Effect: Hashable
    associatedtype Event: Hashable = EmptyModuleItem
	associatedtype Input: Hashable = EmptyModuleItem
	associatedtype Output: Hashable = EmptyModuleItem
    associatedtype State: Hashable
}
