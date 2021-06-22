//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import ReactSwift

final class ___VARIABLE_moduleName___Bios: ComponentBios<___VARIABLE_moduleName___Module> {
    override func received(action: Action) {
        print(action)
        
    }

    override func invoked(effect: Effect) {
        print(effect)
    }

    override func throwed(_ error: Error) {
        print(error)
    }
}