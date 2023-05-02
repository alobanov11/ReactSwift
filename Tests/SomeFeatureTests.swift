import XCTest
import StoreSwift
import Foundation

final class SomeFeatureTests: XCTestCase {

    func testViewDidLoad() async {
        let middleware = SomeFeature.middleware
        let state = SomeFeature.State()
        var env = SomeFeature.Enviroment(fetchSome: { return 0 })
        let effectTask = middleware(state, &env, .viewDidLoad)
        let intents = await effectTask.unwrap(&env)
        XCTAssertEqual(intents, [
            .effect(.setLoading(true)),
            .effect(.setNumber(0)),
            .effect(.setLoading(false)),
        ])
        XCTAssertEqual(env.someValue, "second call")
    }
}
