//
//  Created by Антон Лобанов on 21.06.2021.
//

@testable import ReactSwift

enum MockModule: IModule {
    enum Action {
        case viewDidLoad
    }

    enum Effect {
        case setLoading(Bool)
    }

    enum Event {
        case scrollToTop
    }

    struct State: Hashable {
        var isLoading = false
        var optionalIsLoading: Bool?
    }

	static func build(with parameters: EmptyModuleItem = .init()) -> WeakRoutableModule<MockModule> {
		.init(module: .init(viewController: <#T##UIViewController#>, context: <#T##(EmptyModuleItem) -> Void#>))
	}
}
