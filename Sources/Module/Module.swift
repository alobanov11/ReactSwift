//
//  Created by Антон Лобанов on 25.03.2021.
//

import UIKit

public struct NoEvent: Equatable {
	public init() {}
}

public protocol Module {
	associatedtype Action: Equatable
	associatedtype Effect: Equatable
	associatedtype Event: Equatable = NoEvent
	associatedtype State: Equatable
}
