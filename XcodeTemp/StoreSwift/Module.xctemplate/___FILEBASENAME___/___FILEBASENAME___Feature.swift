//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import StoreSwift

enum ___VARIABLE_featureName___Feature: Feature {

    enum Action: Equatable {

        case viewDidLoad
    }

	enum Effect: Equatable {

        case setLoading(Bool)
	}

    struct Enviroment {}

    struct State: Hashable {

        var isLoading = false
    }

    static var store: Store<___VARIABLE_featureName___Feature> {
        Store(
            initialState: State(),
            enviroment: Enviroment(),
            middleware: middleware,
            reducer: reducer
        )
    }
}

extension ___VARIABLE_featureName___Feature {

    static var middleware: Store<___VARIABLE_featureName___Feature>.Middleware {
        { state, env, action in
            switch action {
            case .viewDidLoad:
                return .effect(.setLoading(true))
            }
        }
    }

    static var reducer: Store<___VARIABLE_featureName___Feature>.Reducer {
        { state, effect in
            switch effect {
            case let .setLoading(value):
                state.isLoading = value
            }
        }
    }
}
