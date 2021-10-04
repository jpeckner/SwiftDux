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

public class MockStore<StoreState: StateProtocol>: StoreProtocol {

    public typealias State = StoreState
    public typealias SubscriptionFields = (subscription: Any, subscriber: AnyObject)

    private(set) public var dispatchedActions: [Action] = []
    public var appendActionCallback: ((Action) -> Void)?

    private(set) public var receivedSubscriptions: [SubscriptionFields] = []
    private(set) public var receivedUnsubscribers: [AnyObject] = []

    private(set) public var numResetCalls = 0

    public var stubState: StoreState?

    // MARK: Methods

    public init() {}

    public func subscribe<Subscription>(
        _ subscription: Subscription
    ) where Subscription: StoreSubscriptionProtocol, StoreState == Subscription.StoreState {
        guard let subscriber = subscription.getSubscriber() else { return }

        let fields = SubscriptionFields(subscription: subscription,
                                        subscriber: subscriber)
        receivedSubscriptions.append(fields)
    }

    public func unsubscribe<S>(_ subscriber: S) where S : StoreSubscriber, StoreState == S.StoreState {
        receivedUnsubscribers.append(subscriber)
    }

    public func dispatch(_ action: Action) {
        dispatchedActions.append(action)
        defer { appendActionCallback?(action) }

        guard let asyncAction = action as? AsyncAction<State> else { return }
        asyncAction.thunk(self.dispatch) { stateReceiverBlock in
            guard let stubState = stubState else {
                XCTFail("Unexpected nil stubState value")
                return
            }

            stateReceiverBlock(stubState)
        }
    }

    public func reset(to state: State) {
        numResetCalls += 1
    }

}

public extension MockStore {

    func isAsyncAction(_ action: Action) -> Bool {
        return action is AsyncAction<State>
    }

    var dispatchedNonAsyncActions: [Action] {
        return dispatchedActions.filter { !isAsyncAction($0) }
    }

    var dispatchedAsyncActions: [Action] {
        return dispatchedActions.filter { isAsyncAction($0) }
    }

}

public extension XCTestCase {

    func waitFor<StoreState: StateProtocol>(_ mockStore: MockStore<StoreState>,
                                            toReachNonAsyncActionCount count: Int,
                                            timeout: TimeInterval = defaultWaitTime,
                                            afterExecuting block: () -> Void) {
        let callbackExpectation = expectation(description: "callbackExpectation")
        mockStore.appendActionCallback = { dispatchedAction in
            guard !mockStore.isAsyncAction(dispatchedAction),
                mockStore.dispatchedNonAsyncActions.count == count
            else { return }

            callbackExpectation.fulfill()
        }

        block()
        waitForExpectations([callbackExpectation], withTimeout: timeout)
    }

    typealias NoDispatchVerificationBlock = () -> Void

    func verifyNoDispatches<StoreState: StateProtocol>(
        from mockStore: MockStore<StoreState>,
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
