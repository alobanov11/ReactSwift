# StoreSwift

StoreSwift is a lightweight library which allows you to make undirection data flow architecture.



## The problems

There is no perfect an architecture which could be fitted to any Application. Each architecture in iOS has scalability issues:
* **MVC**: SOLID principles are violated totaly
* **MVP**: Presenter could turn to God object and it's getting hard to separate a side effect logic and a business logic
* **VIPER/VIP**: In general the same problems as MVP has, but also low readability
* **MVVM**: Must be used with Rx similar libraries and at the beginning could take a time to set up.
* **Redux similar**: It's easy to underastand the dependency between a View and a business logic by undirection data flow



## How to use

First you need to define a module to conform this protocol. It could be a UIViewController module or a separeted UIView part.

```swift
public protocol IModule {
    /// All action which View can have (e.g. viewDidLoad / didTapOnSubmitButton)
    associatedtype Action: Equatable
	
    /// Effect how we want to change state (e.g. setLoading(Bool), setData([String])) 
    associatedtype Effect: Equatable
	
    /// Helper to call some functional on a View directly without changing state
    associatedtype Event: Equatable = EmptyModuleItem
	
    /// State of a View
    associatedtype State: Equatable
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

StoreSwift supports **iOS 9 and up**, and can be compiled with **Swift 4.2 and up**.



## Installation

### Swift Package Manager

The StoreSwift package URL is:

```
`https://github.com/alobanov11/StoreSwift`
```



## License

StoreSwift is licensed under the [Apache-2.0 Open Source license](http://choosealicense.com/licenses/apache-2.0/).

You are free to do with it as you please.  We _do_ welcome attribution, and would love to hear from you if you are using it in a project!
