//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import ReactSwift

final class ___VARIABLE_moduleName___Reducer: Reducer<___VARIABLE_moduleName___Module> {
    override func reduce(state: State, effect: Effect) -> State {
        var newState = state
        
        switch effect {
        case let .setLoading(value):
            newState.isLoading = value
        }
        
        return newState
    }
}