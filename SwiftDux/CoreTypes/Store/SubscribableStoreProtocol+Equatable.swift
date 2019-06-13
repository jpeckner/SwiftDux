//
//  SubscribableStoreProtocol+Equatable.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

extension SubscribableStoreProtocol where State: Equatable {

    public func subscribe<Subscriber: StoreStateSubscriber>(
        _ subscriber: Subscriber
    ) where Subscriber.StoreState == State {
        subscribe(StoreStateSubscription(subscriber: subscriber))
    }

}

extension SubscribableStoreProtocol {

    public func subscribe<Subscriber: SubstatesSubscriber>(
        _ subscriber: Subscriber,
        equatableKeyPaths: Set<EquatableKeyPath<State>>
    ) where Subscriber.StoreState == State {
        subscribe(SubstatesSubscription(subscriber: subscriber,
                                        equatableKeyPaths: equatableKeyPaths))
    }

    public func subscribe<Subscriber: SubstatesSubscriber, E: Equatable>(
        _ subscriber: Subscriber,
        keyPath: KeyPath<State, E>
    ) where Subscriber.StoreState == State {
        subscribe(SubstatesSubscription(subscriber: subscriber,
                                        keyPath: keyPath))
    }

}
