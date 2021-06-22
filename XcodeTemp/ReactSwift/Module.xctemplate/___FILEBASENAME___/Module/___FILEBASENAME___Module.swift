//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import ReactSwift

protocol ___VARIABLE_moduleName___ModuleOutput: AnyObject {
}

protocol ___VARIABLE_moduleName___ModuleInput: AnyObject {
}

enum ___VARIABLE_moduleName___Module: IComponent {
    enum Action {
        case viewDidLoad
    }

    enum Effect {
        case setLoading(Bool)
    }

    struct State: Hashable {
        var isLoading = false
    }

    static func build() -> (___VARIABLE_moduleName___ViewController, ___VARIABLE_moduleName___ModuleOutput, ___VARIABLE_moduleName___ModuleInput) {
        let middleware = ___VARIABLE_moduleName___Middleware()
        let reducer = ___VARIABLE_moduleName___Reducer()
        let bios = ___VARIABLE_moduleName___Bios()
        
        let store = Store(
            middleware: middleware,
            reducer: reducer,
            initialState: .init(),
            bios: bios
        )
        
        let view = ___VARIABLE_moduleName___ViewController(store: store)
        
        return (view, middleware, middleware)
    }
}
