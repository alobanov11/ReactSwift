import Foundation
import StoreSwift

struct ___VARIABLE_moduleName___UseCase: UseCase {
    struct Props: Equatable {
        var isLoading = false
    }

    enum Action {
        case viewAppeared
    }

    struct Router {
    }

    let router: Router
}

extension ___VARIABLE_moduleName___UseCase {
    var middleware: Middleware {
        return { state, action in
            switch action {
            case .viewAppeared:
                return .mutate {
                    $0.isLoading = true
                }
            }
        }
    }
}
