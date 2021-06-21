//
//  Created by Антон Лобанов on 30.03.2021.
//

import XCTest
@testable import ReactSwift

final class ComponentBiosTests: XCTestCase {
    private final class MockBios: ComponentBios<MockComponent> {
        var isActionReceived: Bool?
        var isEffectInvoked: Bool?
        var isErrorThrowed: Bool?

        override func received(action: Action) {
            self.isActionReceived = true
        }

        override func invoked(effect: Effect) {
            self.isEffectInvoked = true
        }

        override func throwed(_ error: Error) {
            self.isErrorThrowed = true
        }
    }

    private var store: Store<MockComponent>!
    private var middleware: Middleware<MockComponent>!
    private var bios: MockBios!


    override func setUp() {
        super.setUp()
        let bios = MockBios()
        let middleware = Middleware<MockComponent>()
        self.store = .init(middleware: middleware, reducer: .init(), initialState: .init(), bios: bios)
        self.middleware = middleware
        self.bios = bios
    }

    func testActionReceived() throws {
        // Arrange
        XCTAssertEqual(self.bios.isActionReceived, nil)

        // Act
        self.store.dispatch(.viewDidLoad)

        // Assert
        XCTAssertEqual(self.bios.isActionReceived, true)
    }

    func testEffectInvoked() throws {
        // Arrange
        XCTAssertEqual(self.bios.isEffectInvoked, nil)

        // Act
        self.middleware.invoke(effect: .setLoading(true))

        // Assert
        XCTAssertEqual(self.bios.isEffectInvoked, true)
    }

    func testThrowedError() throws {
        // Arrange
        XCTAssertEqual(self.bios.isErrorThrowed, nil)

        // Act
        self.middleware.throw(NSError(domain: "", code: 0, userInfo: nil))

        // Assert
        XCTAssertEqual(self.bios.isErrorThrowed, true)
    }
}
