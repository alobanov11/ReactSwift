import Foundation
import StoreSwift

final class SomeService {

    func fetch() async -> Int {
        return 1
    }
}

enum SomeFeature: Feature {

    enum Action {

        case viewDidLoad
    }

    enum Effect: Equatable {

        case setLoading(Bool)
        case setNumber(Int)
    }

    struct Enviroment {
        var someValue = ""
        let fetchSome: () async -> Int
    }

    struct State: Equatable {

        var isLoading = false
        var number: Int?
    }
}

extension SomeFeature {

    static var middleware: Store<SomeFeature>.Middleware {
        { state, env, intent in
            switch intent {
            case .action(.viewDidLoad):
                env.someValue = "first call"
                return .combine(
                    .effect(.setLoading(true)),
                    .run { env in
                        let number = await env.fetchSome()
                        if env.someValue == "first call" {
                            env.someValue = "second call"
                        }
                        return .combine(
                            .effect(.setNumber(number)),
                            .effect(.setLoading(false))
                        )
                    }
                )
            }
        }
    }

    static var reducer: Store<SomeFeature>.Reducer {
        { state, effect in
            switch effect {
            case let .setLoading(value):
                state.isLoading = value
            case let .setNumber(value):
                state.number = value
            }
        }
    }
}
