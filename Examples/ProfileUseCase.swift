import Foundation
import StoreSwift

struct ProfileUseCase: UseCase {

    struct Props: Equatable {

        var isLoading = false
    }

    struct Router {
    }

    let router: Router
}

extension Action where U == ProfileUseCase {

    static let viewAppeared = Self { props, useCase in
        await props {
            $0.isLoading = true
        }
    }
}


