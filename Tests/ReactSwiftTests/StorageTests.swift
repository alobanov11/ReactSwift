//
//  Created by Антон Лобанов on 30.03.2021.
//

import XCTest
@testable import ReactSwift

final class StorageTests: XCTestCase {
    private var storage: Storage<MockModule.State>!

    override func setUp() {
        super.setUp()
        self.storage = .init(.init())
    }

    func testCallsAndOrderOfSubscribers() throws {
        final class Value { var value: [Int] = [] }

        // Arrange
        let result = Value()

        self.storage.subscribe(self) { [result] _, _, _ in
            result.value.append(1)
        }

        self.storage.subscribe(self) { [result] _, _, _ in
            result.value.append(2)
        }

        self.storage.subscribe(self) { [result] _, _, _ in
            result.value.append(3)
        }

        XCTAssertEqual(result.value, [])

        // Act
        self.storage.mutate {
            $0.isLoading = true
        }

        // Assert
        XCTAssertEqual(result.value, [1, 2, 3])
    }

    func testMutateValue() throws {
        // Arrange
        XCTAssertEqual(self.storage.value, .init())

        // Act
        self.storage.mutate {
            $0.isLoading = true
        }

        // Assert
        XCTAssertEqual(self.storage.value.isLoading, true)
    }
}

