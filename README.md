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
    }
	
    enum Action {
        case viewAppeared
    }
    
    enum Effect {
        case setLoading(Bool)
    }
	
    var reducer: Reducer {
        return { state, effect in
            switch effect {
            case let .setLoading(value):
                state.isLoading = value
            }
        }
    }
    
    var middleware: Middleware {
        return { state, action in
            switch action {
            case let .viewAppeared(value):
                return .merge(
                    .effect(.setLoading(true),
                    .run { // perform asyncronous task and return EffectTask }
                )
            }
        }
    }
}
```


Then simple use it in view:

```swift
@StateObject var store: Store<ProfileUseCase>
...
store.isLoading
...
store.send(.viewAppeared)
...
store.$state.sink { state in ... }

```

Simple to use.

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
