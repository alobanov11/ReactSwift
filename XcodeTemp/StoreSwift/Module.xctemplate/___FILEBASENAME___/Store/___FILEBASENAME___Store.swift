//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import StoreSwift

final class ___VARIABLE_moduleName___Store: Store<___VARIABLE_moduleName___Module> {
	override func dispatch(_ action: Action) {
		switch action {
		case .viewDidLoad:
			self.invoke(effect: .setLoading(true))
		}
	}

	override class func reduce(_ state: inout State, effect: Effect) {
		switch effect {
		case let .setLoading(value):
			state.isLoading = value
		}
	}
}
