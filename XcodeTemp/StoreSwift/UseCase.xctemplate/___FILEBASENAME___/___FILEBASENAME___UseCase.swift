import SwiftUI
import StoreSwift

// MARK: UseCase
struct ___VARIABLE_useCaseName___UseCase: UseCase {
    struct State: Hashable {
        var isLoading = false
    }

    enum Action: Equatable {
        case viewAppear
    }

    static let actionReducer: ActionReducer = { action, state, useCase in
        switch action {
        case .viewAppear:
            state.isLoading = true
            return .none
        }
    }

    static let preview = Self()
}
