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

    static let viewAppeared = Self {
        await $0.setProps(\.isLoading, true)
    }
}
