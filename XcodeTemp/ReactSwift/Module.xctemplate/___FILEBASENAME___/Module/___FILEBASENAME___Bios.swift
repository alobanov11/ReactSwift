//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import ReactSwift

final class ___VARIABLE_moduleName___Bios: ModuleBios<___VARIABLE_moduleName___Module> {
    override func received(action: Action) {
        print(action)
    }

    override func invoked(effect: Effect) {
        print(effect)
    }

    override func invoked(event: Event) {
        print(event)
    }

    override func throwed(_ error: Error) {
        print(error)
    }
}
