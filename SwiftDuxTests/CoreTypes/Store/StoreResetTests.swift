//
//  StoreResetTests.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import SwiftDux
import SwiftDuxTestComponents
import XCTest

class StoreResetTests: XCTestCase {

    private var store: Store<TestAppState>!

    override func setUp() {
        super.setUp()

        store = Store(reducer: TestAppStateReducer.reduce,
                      initialState: TestAppState())
    }

    func testResetRemovesCurrentSubscriptions() {
        var oldSubscriptionWasNotified = false
        let mockSubscription = MockStoreSubscription<TestAppState>()
        waitUntil(mockSubscription, subscribesTo: store)
        mockSubscription.newStateCallback = { _, _ in oldSubscriptionWasNotified = true }

        store.reset(to: TestAppState())
        let addedSubscription = MockStoreSubscription<TestAppState>()
        store.subscribe(addedSubscription)
        waitUntilStateUpdates(to: TestAppState(intValue: 5, stringValue: nil),
                              afterDispatching: SetIntSubstateAction(5),
                              andNotifiying: addedSubscription,
                              with: store)

        XCTAssertFalse(oldSubscriptionWasNotified)
    }

    func testDispatchDelayedUntilAfterResetDoesNotMutateState() {
        var delayedDispatchHasOccurred = false
        let delayedDispatchExpectation = expectation(description: "delayedDispatchExpectation")
        let longDelay: TimeInterval = 2.0
        let oldThunkIntActionValue = 5

        // When a thunk is dispatched before a call to reset()...
        store.dispatch(AsyncAction<TestAppState> { dispatch, _ in
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + longDelay) {
                dispatch(SetIntSubstateAction(oldThunkIntActionValue))
                delayedDispatchHasOccurred = true
                delayedDispatchExpectation.fulfill()
            }
        })
        store.reset(to: TestAppState())

        // and the state is then mutated...
        let postResetSubscription = MockStoreSubscription<TestAppState>()
        store.subscribe(postResetSubscription)
        let newIntValue = oldThunkIntActionValue + 1
        waitUntilStateUpdates(to: TestAppState(intValue: newIntValue, stringValue: nil),
                              afterDispatching: SetIntSubstateAction(newIntValue),
                              andNotifiying: postResetSubscription,
                              with: store)

        // and the thunk performs a dispatch long after the call to reset()...
        XCTAssertFalse(delayedDispatchHasOccurred)
        waitForExpectations([delayedDispatchExpectation], withTimeout: longDelay + 0.1)

        // the old thunk's dispatch does not mutate the state
        let mostRecentIntValue = postResetSubscription.receivedStates.last?.newState.intSubstate.value
        let oldThunkMutatedState = mostRecentIntValue == oldThunkIntActionValue
        XCTAssertFalse(oldThunkMutatedState)
    }

    func testResetSetsStateToProvidedValue() {
        let newState = TestAppState(intValue: 100,
                                          stringValue: "Brand new string!")
        store.reset(to: newState)

        let postResetSubscription = MockStoreSubscription<TestAppState>()
        waitUntil(postResetSubscription, subscribesTo: store)
        XCTAssertEqual(postResetSubscription.receivedInitialState, newState)
    }

    func testDispatchingPlainActionAfterReset() {
        store.reset(to: TestAppState())

        let postResetSubscription = MockStoreSubscription<TestAppState>()
        store.subscribe(postResetSubscription)

        let action = SetIntSubstateAction(30)
        waitUntilStateUpdates(to: TestAppState(intValue: 30, stringValue: nil),
                              afterDispatching: action,
                              andNotifiying: postResetSubscription,
                              with: store)
    }

    func testDispatchingAsyncActionAfterReset() {
        store.reset(to: TestAppState())

        let postResetSubscription = MockStoreSubscription<TestAppState>()
        store.subscribe(postResetSubscription)

        let asyncAction = AsyncAction<TestAppState> { dispatch, _ in
            dispatch(SetIntSubstateAction(30))
        }
        waitUntilStateUpdates(to: TestAppState(intValue: 30, stringValue: nil),
                              afterDispatching: asyncAction,
                              andNotifiying: postResetSubscription,
                              with: store)
    }

}
