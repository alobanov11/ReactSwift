import Foundation
import StoreSwift

struct ___VARIABLE_moduleName___UseCase: UseCase {

    struct Props: Equatable {

        var isLoading = false
    }

    struct Router {
    }

    let router: Router
}

extension Action where U == ___VARIABLE_moduleName___UseCase {

    static let viewAppeared = Self {
        await $0.setProps(\.isLoading, true)
    }
}
