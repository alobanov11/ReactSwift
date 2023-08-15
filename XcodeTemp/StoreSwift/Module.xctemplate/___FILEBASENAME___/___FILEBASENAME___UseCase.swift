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

    var reducer: Reducer {
        return { state, effect in
            switch effect {
            case let .setLoading(value):
                state.isLoading = value
            }
        }
    }

    var middleware: Middleware {
        return { state, action in
            switch action {
            case .viewAppeared:
                return .effect(.setLoading(true))
            }
        }
    }
}
