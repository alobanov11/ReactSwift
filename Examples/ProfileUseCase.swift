import Foundation
import StoreSwift

struct ProfileUseCase: UseCase {
    struct State: Equatable {
        var isLoading = false
    }

    enum Action {
        case viewAppeared
    }

    enum Effect {
        case setLoading(Bool)
    }

    let id: String
}

extension ProfileUseCase {
    static var reduce: Reducer {
        return { state, effect in
            switch effect {
            case let .setLoading(value):
                state.isLoading = value
            }
        }
    }

    static var middleware: Middleware {
        var data: [String: Any]?
        return { state, action in
            switch action {
            case .viewAppeared:
                data = [:]
                return .effect(.setLoading(true))
            }
        }
    }
}
