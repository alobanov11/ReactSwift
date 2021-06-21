//
//  Created by Антон Лобанов on 30.03.2021.
//

import XCTest
@testable import ReactSwift

final class StoreTests: XCTestCase {
    private final class MockMiddleware: Middleware<MockComponent> {
        override func handle(action: Action) {
            switch action {
            case .viewDidLoad:
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
                newState.optionalIsLoading = value
            }
            return newState
        }
    }

    private var store: Store<MockComponent>!
    private var middleware: MockMiddleware!

    override func setUp() {
        super.setUp()
        self.middleware = .init()
        self.store = .init(middleware: self.middleware, reducer: MockReducer(), initialState: .init())
    }

    func testObserveByHandler() throws {
        final class Value { var value = false }

        // Arrange
        let expectation = self.expectation(description: "Test")
        let result = Value()
        self.store.observe { [result] in result.value = $0.isLoading }

        XCTAssertEqual(self.store.state.isLoading, false)

        // Act
        self.store.dispatch(.viewDidLoad)

        // Assert
        DispatchQueue.main.async { expectation.fulfill() }
        self.waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(result.value, true)
    }

    func testObserveByKeypathHandler() throws {
        final class Value { var value = false }

        // Arrange
        let expectation = self.expectation(description: "Test")
        let result = Value()
        self.store.observe(\.isLoading) { [result] in result.value = $0 }

        XCTAssertEqual(self.store.state.isLoading, false)

        // Act
        self.store.dispatch(.viewDidLoad)

        // Assert
        DispatchQueue.main.async { expectation.fulfill() }
        self.waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(result.value, true)
    }

    func testBindToObjectByKeypath() throws {
        final class Value { var value = false }

        // Arrange
        let expectation = self.expectation(description: "Test")
        let result = Value()
        self.store.bind(\.isLoading, to: result, \Value.value)

        XCTAssertEqual(self.store.state.isLoading, false)

        // Act
        self.store.dispatch(.viewDidLoad)

        // Assert
        DispatchQueue.main.async { expectation.fulfill() }
        self.waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(result.value, true)
    }

    func testBindOptionalToObjectByKeypath() throws {
        final class Value { var value: Bool? }

        // Arrange
        let expectation = self.expectation(description: "Test")
        let result = Value()
        self.store.bind(\.isLoading, to: result, \Value.value)

        XCTAssertEqual(self.store.state.isLoading, false)

        // Act
        self.store.dispatch(.viewDidLoad)

        // Assert
        DispatchQueue.main.async { expectation.fulfill() }
        self.waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(result.value, true)
    }

    func testBindWithMapToObjectByKeypath() throws {
        final class Value { var value = "" }

        // Arrange
        let expectation = self.expectation(description: "Test")
        let result = Value()
        self.store.bind(\.isLoading, to: result, \Value.value) { $0 ? "true" : "false" }

        XCTAssertEqual(self.store.state.isLoading, false)

        // Act
        self.store.dispatch(.viewDidLoad)

        // Assert
        DispatchQueue.main.async { expectation.fulfill() }
        self.waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(result.value, "true")
    }

    func testBindOptionalWithMapToObjectByKeypath() throws {
        final class Value { var value = false }

        // Arrange
        let expectation = self.expectation(description: "Test")
        let result = Value()
        self.store.bind(\.optionalIsLoading, to: result, \Value.value) { $0 == true }

        XCTAssertEqual(self.store.state.isLoading, false)

        // Act
        self.store.dispatch(.viewDidLoad)

        // Assert
        DispatchQueue.main.async { expectation.fulfill() }
        self.waitForExpectations(timeout: 0.1, handler: nil)
        XCTAssertEqual(result.value, true)
    }
}

