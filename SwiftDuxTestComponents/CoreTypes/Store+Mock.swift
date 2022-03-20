//
//  Store+Mock.swift
//  SwiftDuxTestComponents
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

import SwiftDux
import XCTest

public class MockStore<TAction: Action, TState: StateProtocol>: StoreProtocol, TestDispatchingStoreProtocol {

    public typealias State = TState
    public typealias SubscriptionFields = (subscription: Any, subscriber: AnyObject)

    private(set) public var dispatchedActions: [TAction] = []
    public var appendActionCallback: ((TAction) -> Void)?

    private(set) public var receivedSubscriptions: [SubscriptionFields] = []
    private(set) public var receivedUnsubscribers: [AnyObject] = []

    private(set) public var numResetCalls = 0

    public var stubState: TState?

    // MARK: Methods

    public init() {}

    public func subscribe<Subscription>(
        _ subscription: Subscription
    ) where Subscription: StoreSubscriptionProtocol, TState == Subscription.StoreState {
        guard let subscriber = subscription.getSubscriber() else { return }

        let fields = SubscriptionFields(subscription: subscription,
                                        subscriber: subscriber)
        receivedSubscriptions.append(fields)
    }

    public func unsubscribe<S>(_ subscriber: S) where S : StoreSubscriber, TState == S.StoreState {
        receivedUnsubscribers.append(subscriber)
    }

    public func dispatch(_ action: TAction) {
        dispatchedActions.append(action)
        appendActionCallback?(action)
    }

    public func reset(to state: TState) {
        numResetCalls += 1
    }

}

public extension XCTestCase {

    func waitFor<TAction: Action, TState: StateProtocol>(
        _ mockStore: MockStore<TAction, TState>,
        toReachActionCount count: Int,
        timeout: TimeInterval = defaultWaitTime,
        afterExecuting block: () -> Void
    ) {
        let callbackExpectation = expectation(description: "callbackExpectation")
        mockStore.appendActionCallback = { dispatchedAction in
            guard mockStore.dispatchedActions.count == count else {
                return
            }

            callbackExpectation.fulfill()
        }

        block()
        waitForExpectations([callbackExpectation], withTimeout: timeout)
    }

    typealias NoDispatchVerificationBlock = () -> Void

    func verifyNoDispatches<TAction: Action, TState: StateProtocol>(
        from mockStore: MockStore<TAction, TState>,
        afterExecuting block: () -> Void
    ) -> NoDispatchVerificationBlock {
        let preExecutionDispatchCount = mockStore.dispatchedActions.count
        block()

        Thread.sleep(forTimeInterval: defaultWaitTime)

        return {
            XCTAssertEqual(mockStore.dispatchedActions.count, preExecutionDispatchCount)
        }
    }

}
