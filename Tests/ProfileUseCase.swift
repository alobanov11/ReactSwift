import Foundation
import StoreSwift

struct ProfileUseCase: UseCase {
    struct State: Equatable {
        var isLoading = false
        var profileID: Int64?
        var error: String?
    }

    enum Action {
        case viewDidLoad
    }

    enum Effect: Equatable {
        enum FetchProfileError: Error, Equatable {
            case someError
        }

        case didReceiveProfile(Result<Int64, FetchProfileError>)
    }

    static let actionReducer: ActionReducer = { action, state, useCase in
        switch action {
        case .viewDidLoad:
            state.isLoading = true
            useCase.isViewLoaded = true
            return .run { [useCase] in
                do {
                    let profileID = try await useCase.fetchProfile()
                    return .effect(.didReceiveProfile(.success(profileID)))
                }
                catch {
                    return .effect(.didReceiveProfile(.failure(.someError)))
                }
            }
        }
    }

    static let effectReducer: EffectReducer = { effect, state, useCase in
        switch effect {
        case let .didReceiveProfile(.success(profileID)):
            state.isLoading = false
            state.profileID = profileID
            useCase.isProfileLoaded = true

        case let .didReceiveProfile(.failure(error)):
            state.isLoading = false
            state.error = error.localizedDescription
        }
        return .none
    }

    var isViewLoaded = false
    var isProfileLoaded = false

    let fetchProfile: () async throws -> Int64
}
