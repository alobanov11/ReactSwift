import Foundation
import SwiftUI
import StoreSwift
import XCTest

final class ProfileUseCaseTests: XCTestCase {
    func testViewDidLoadWhenResultIsSuccessfull() async throws {
        try await TestStore<ProfileUseCase>(
            .action(.viewDidLoad),
            useCase: ProfileUseCase(
                fetchProfile: { 1 }
            ),
            state: ProfileUseCase.State()
        )
        .assert(\.isLoading, true)
        .assert(\.isViewLoaded, true)
        .assert([.didReceiveProfile(.success(1))])
        .apply()
        .assert(\.isLoading, false)
        .assert(\.profileID, 1)
        .assert(\.isProfileLoaded, true)
    }
}
