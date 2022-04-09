//
//  Created by Антон Лобанов on 25.03.2021.
//

import UIKit

public struct EmptyModuleItem: Equatable {
	public init() {}
}

public protocol IModule {
	associatedtype Action: Equatable
	associatedtype Event: Equatable = EmptyModuleItem
	associatedtype State: Equatable
}
