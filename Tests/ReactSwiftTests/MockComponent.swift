//
//  Created by Антон Лобанов on 21.06.2021.
//

@testable import ReactSwift

enum MockComponent: IComponent {
    enum Action {
        case viewDidLoad
    }

    enum Effect {
        case setLoading(Bool)
    }

    struct State: Hashable {
        var isLoading = false
        var optionalIsLoading: Bool?
    }
}
