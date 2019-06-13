//
//  StoreProtocol.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

public protocol StoreProtocol:
    DispatchingStoreProtocol,
    ResettableStoreProtocol,
    SubscribableStoreProtocol {}

public protocol DispatchingStoreProtocol {
    func dispatch(_ action: Action)
}

public protocol ResettableStoreProtocol {
    associatedtype State: StateProtocol

    /**
     Ignores all pending Actions, removes all subscriptions, and resets the store's state to the value provided.

     Note: even after calling reset(), it is still possible that pending Actions will be executed, albeit without any
     effect on the store's state or subscribers. If you want to cancel any operations embedded in an Action, such as
     a network request, you'll need to do so with object directly responsible for the operation. This method simply
     nullifies any effects of such operations on the store.
     */
    func reset(to state: State)
}

public protocol SubscribableStoreProtocol {
    associatedtype State: StateProtocol

    func subscribe<Subscription: StoreSubscriptionProtocol>(
        _ subscription: Subscription
    ) where Subscription.StoreState == State


    func unsubscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreState == State
}
