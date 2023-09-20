import Foundation
import StoreSwift

struct ___VARIABLE_moduleName___UseCase: UseCase {
    struct State: Equatable {
        var isLoading = false
    }

    enum Action {
        case viewAppeared
    }

    enum Effect {
        case setLoading(Bool)
    }

    struct Router {
    }

    let router: Router
}

extension ___VARIABLE_moduleName___UseCase {
    static var reduce: Reducer {
        return { state, effect in
            switch effect {
            case let .setLoading(value):
                state.isLoading = value
            }
        }
    }

    static var middleware: Middleware {
        return { state, action in
            switch action {
            case .viewAppeared:
                return .none
            }
        }
    }
}
