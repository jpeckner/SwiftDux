//
//  StoreProtocol.swift
//  SwiftDux
//
//  Copyright (c) 2019 Justin Peckner
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
