//
//  SubscribableStoreProtocol+Equatable.swift
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

public extension SubscribableStoreProtocol where TState: Equatable {

    func subscribe<Subscriber: StoreStateSubscriber>(
        _ subscriber: Subscriber
    ) where Subscriber.StoreState == TState {
        subscribe(StoreStateSubscription(subscriber: subscriber))
    }

}

public extension SubscribableStoreProtocol {

    func subscribe<Subscriber: SubstatesSubscriber>(
        _ subscriber: Subscriber,
        equatableKeyPaths: Set<EquatableKeyPath<TState>>
    ) where Subscriber.StoreState == TState {
        subscribe(SubstatesSubscription(subscriber: subscriber,
                                        equatableKeyPaths: equatableKeyPaths))
    }

    func subscribe<Subscriber: SubstatesSubscriber, E: Equatable>(
        _ subscriber: Subscriber,
        keyPath: KeyPath<TState, E>
    ) where Subscriber.StoreState == TState {
        subscribe(SubstatesSubscription(subscriber: subscriber,
                                        keyPath: keyPath))
    }

}
