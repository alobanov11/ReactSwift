# StoreSwift

StoreSwift is a streamlined library designed to facilitate undirectional data flow architecture.

## The Challenges

No single architecture is perfectly suited for every application. Many architectures in iOS come with scalability challenges:
* **MVC**: Often completely violates the SOLID principles.
* **MVP**: The presenter can morph into a "God object," making it challenging to differentiate between side effect logic and business logic.
* **VIPER/VIP**: Shares similar issues with MVP, coupled with reduced readability.
* **MVVM**: Typically requires integration with Rx-like libraries and can be time-consuming to set up initially.
* **Redux-style**: Makes it simpler to understand the relationship between a View and business logic through undirectional data flow.

## How to use

First you need to define a UseCase:

```swift
struct ProfileUseCase: UseCase {
    struct State: Equatable {
        var isLoading = false
        var name: String?
    }
	
    enum Action {
        case viewAppeared
    }
    
    enum Effect {
        case setLoading(Bool)
        case setName(String)
    }
	
    var reducer: Reducer {
        return { state, action in
            switch action {
            case .
            }
        }
    }
}
```

Then you need to create your own Store:

```swift
final class AuthStore: Store<AuthModule> {
    /// The view calls this function 
    override func dispatch(_ action: Action) {
        switch action {
        case .viewDidLoad:
            self.invoke(effect: .setLoading(true))
        }
    }

    /// Static function which can change State by an effect
    override class func reduce(_ state: inout State, effect: Effect) {
        switch effect {
        case let .setLoading(value):
            state.isLoading = value
        }
    }
}
```

Then provide it to the View:

```swift
final class AuthViewController: UIViewController {
    typealias Module = AuthModule
    
	/// Store conforms ViewStore but it doesn't have internal methods
    private let store: ViewStore<Module>

    init(store: ViewStore<Module>) {
        self.store = store
        super.init()
    }

    /// ViewStore object contains a lot of observable methods
    /// These methods can help you to make View reactive but without using complex instruments like Rx
    override func viewDidLoad() {
        super.viewDidLoad()
        self.store
            .bind(\.isSubmitEnabled, to: self, \AuthViewController.isSubmitEnabled)
            .observe(\.code) { [weak self] code in self?.setCode(code) }
            .listen { [weak self] event in
                switch event {
                case let .setActive(value):
                    self?.isActive = value
                }
            }
            .catch { [weak self] error in
                self?.showError(error)
            }
            .dispatch(.viewDidLoad)
    }
}
```

As I said, it looks pretty easy.)


## Requirements

StoreSwift supports **iOS 13 and up**, and can be compiled with **Swift 5.5 and up**.



## Installation

### Swift Package Manager

The StoreSwift package URL is:

```
`https://github.com/alobanov11/StoreSwift`
```



## License

StoreSwift is licensed under the [Apache-2.0 Open Source license](http://choosealicense.com/licenses/apache-2.0/).

You are free to do with it as you please.  We _do_ welcome attribution, and would love to hear from you if you are using it in a project!
