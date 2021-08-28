//
//  Created by ___FULLUSERNAME___ on ___DATE___
//

import ReactSwift
import UIKit

final class ___VARIABLE_moduleName___ViewController: UIViewController {
    typealias Module = ___VARIABLE_moduleName___Module

    private let store: Store<Module>

    init(store: Store<Module>) {
        self.store = store
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.store.dispatch(.viewDidLoad)
    }
}

// MARK: - Private

private extension ___VARIABLE_moduleName___ViewController {
}
