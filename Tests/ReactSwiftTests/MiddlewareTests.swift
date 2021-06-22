//
//  Created by Антон Лобанов on 30.03.2021.
//

import XCTest
@testable import ReactSwift

final class MiddlewareTests: XCTestCase {
    private final class MockMiddleware: Middleware<MockComponent> {
        var isViewDidLoadError = false
        override func handle(action: Action) {
            switch action {
            case .viewDidLoad:
                guard self.isViewDidLoadError == false else {
                    self.throw(NSError(domain: "", code: 0, userInfo: nil))
                    return
                }
                self.invoke(effect: .setLoading(true))
            }
        }
    }

    private final class MockReducer: Reducer<MockComponent> {
        override func reduce(state: State, effect: Effect) -> State {
            var newState = state
            switch effect {
            case let .setLoading(value):
                newState.isLoading = value
            }
            return newState
        }
    }

    private var store: Store<MockComponent>!
    private var middleware: MockMiddleware!

    override func setUp() {
        super.setUp()
        let middleware = MockMiddleware()
        self.store = .init(middleware: middleware, reducer: MockReducer(), initialState: .init())
        self.middleware = middleware
    }

    func testIsLoadingTrueAfterDispatchViewDidLoad() throws {
        // Arrange
        XCTAssertEqual(self.store.state.isLoading, false)

        // Act
        self.store.dispatch(.viewDidLoad)

        // Assert
        XCTAssertEqual(self.store.state.isLoading, true)
    }

    func testErrorThrowedAfterDispatchViewDidLoad() throws {
        final class Value { var value: Bool? }

        // Arrange
        let result = Value()
        self.middleware.isViewDidLoadError = true
        self.store.catch { [result] _ in result.value = true }

        XCTAssertEqual(self.store.state.isLoading, false)
        XCTAssertEqual(result.value, nil)

        // Act
        self.store.dispatch(.viewDidLoad)

        // Assert
        XCTAssertEqual(result.value, true)
    }
}
