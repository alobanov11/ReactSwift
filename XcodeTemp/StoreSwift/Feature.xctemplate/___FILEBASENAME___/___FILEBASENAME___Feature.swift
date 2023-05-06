//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import SwiftUI
import StoreSwift

public enum ___VARIABLE_featureName___Feature: Feature {
    public struct Router {
        public init() {}
    }

    public enum Action: Equatable {
        case viewAppear
    }

    public enum Effect: Equatable {
        case setLoading(Bool)
	}

    public struct Enviroment {
        public let router: Router

        public init(
            router: Router = Router()
        ) {
            self.router = router
        }
    }

    public struct State: Hashable {
        public var isLoading: Bool

        public init(isLoading: Bool = false) {
            self.isLoading = isLoading
        }
    }
}

public extension ___VARIABLE_featureName___Feature {
    @MainActor
    static func view(
        with router: Router
    ) -> some View {
        ___VARIABLE_featureName___View(store: Store(
            initialState: State(),
            enviroment: Enviroment(router: router),
            middleware: middleware,
            reducer: reducer
        ))
    }

    static var middleware: Middleware {
        { state, env, intent in
            switch intent {
            case .action(.viewAppear):
                return .effect(.setLoading(true))
            }
        }
    }

    static var reducer: Reducer {
        { state, effect in
            switch effect {
            case let .setLoading(value):
                state.isLoading = value
            }
        }
    }
}
