import Foundation
import StoreSwift

struct ___VARIABLE_moduleName___UseCase: UseCase {
    
    struct Props: Equatable {
        
        var isLoading = false
    }
}

extension Action where U == ___VARIABLE_moduleName___UseCase {

    static let viewAppeared = Self { context in
        await context {
            $0.isLoading = true
        }
    }
}
