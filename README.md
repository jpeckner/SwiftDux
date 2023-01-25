# jpeckner/SwiftDux

SwiftDux is a Swift implementation of [Redux](https://github.com/reactjs/redux). It closely adheres to the original Redux structure defined by [Dan Abramov](https://github.com/gaearon). SwiftDux originally began as a fork of [ReSwift](https://github.com/ReSwift/ReSwift), but eventually diverged into its own project due substantial interface and implementation differences. Key features of SwiftDux include:

- **Thread safety**: in Redux, all state modifications [must be performed one-by-one](https://redux.js.org/introduction/three-principles#state-is-read-only). SwiftDux guarantees this by performing all state modifications, as well as adding and removing subscribers, on a serial `OperationQueue`. State reads in asynchronous actions are also dispatched on the same queue, ensuring data integrity.
- **Easy-to-use subscriptions**: SwiftDux includes two simple classes for handling subscriptions- `StoreStateSubscription`, for subscribers who want to be notified about any change at all to the global state; and `SubstatesSubscription`, for subscribers who only want to be notified of changes to one or more specific keypaths of the global state. While these two classes cover the vast majority of use-cases, callers can create a custom implementation of `StoreSubscriptionProtocol` if they wish.
- **Type safety**: SwiftDux does not use force-casts or implicit-unwraps anywhere in its source code. Subscriptions also capture your app's specific state type as an `associatedtype`, rather than as `Any`; this eliminates the possibility of subscribers not being updated because of a downcast failure.

## Installing

### CocoaPods

Add `pod 'SwiftDux', :git => 'https://github.com/jpeckner/SwiftDux.git', :branch => 'master'` to your `Podfile`, then run `pod install`.

### Carthage

Add `github "jpeckner/SwiftDux"` to your `Cartfile`, then run `carthage update SwiftDux --platform iOS`.

### Manually

Simply add `SwiftDux.xcodeproj` to your workspace.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
