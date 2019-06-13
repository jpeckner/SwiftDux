//
//  Store+Mock.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

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
