//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import ReactSwift

struct ___VARIABLE_moduleName___Module: IModule {
    enum Action {
        case viewDidLoad
    }

    enum Effect {
        case setLoading(Bool)
    }

    struct State: Hashable {
        var isLoading = false
    }

    func build() -> ___VARIABLE_moduleName___ViewController {
        let store = ___VARIABLE_moduleName___Store(
			initialState: .init()
		)
        
        let view = ___VARIABLE_moduleName___ViewController(store: store)
        
        return view
    }
}
