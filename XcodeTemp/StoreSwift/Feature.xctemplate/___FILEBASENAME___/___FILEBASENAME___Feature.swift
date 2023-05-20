import SwiftUI
import StoreSwift

// MARK: Enviroment
public struct ___VARIABLE_featureName___Enviroment {
    static let preview = ___VARIABLE_featureName___Enviroment()

    public init() {}
}

// MARK: Init feature
@MainActor
public func ___VARIABLE_featureName___ViewWith(
    env: ___VARIABLE_featureName___Enviroment
) -> some View {
    ___VARIABLE_featureName___View(store: Store(
        initialState: ___VARIABLE_featureName___Feature.State(),
        context: ___VARIABLE_featureName___Feature.Context(env: env),
        middleware: ___VARIABLE_featureName___Feature.middleware,
        reducer: ___VARIABLE_featureName___Feature.reducer
    ))
}

// MARK: Feature
enum ___VARIABLE_featureName___Feature: Feature {
    enum Action: Equatable {
        case viewAppear
    }

    enum Effect: Equatable {
        case setLoading(Bool)
	}

    struct Context {
        static let preview = Context(env: .preview)

        let env: ___VARIABLE_featureName___Enviroment
    }

    struct State: Hashable {
        var isLoading = false
    }
}

// MARK: Middleware
extension ___VARIABLE_featureName___Feature {
    static var middleware: Middleware {
        { state, ctx, intent in
            switch intent {
            case .action(.viewAppear):
                return .effect(.setLoading(true))
            }
        }
    }
}

// MARK: Reducer
extension ___VARIABLE_featureName___Feature {
    static var reducer: Reducer {
        { state, effect in
            switch effect {
            case let .setLoading(value):
                state.isLoading = value
            }
        }
    }
}
