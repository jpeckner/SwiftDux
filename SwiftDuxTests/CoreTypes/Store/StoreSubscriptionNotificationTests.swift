//
//  StoreSubscriptionNotificationTests.swift
//  SwiftDuxTests
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import SwiftDux
import SwiftDuxTestComponents
import XCTest

class StoreSubscriptionNotificationTests: XCTestCase {

    private var mockSubscriber: MockStoreStateSubscriber<TestAppState>!
    private var mockSubscription: MockStoreSubscription<TestAppState>!
    private var store: Store<TestAppState>!

    override func setUp() {
        super.setUp()

        mockSubscriber = MockStoreStateSubscriber()
        mockSubscription = MockStoreSubscription(subscriber: mockSubscriber)
        store = Store(reducer: TestAppStateReducer.reduce,
                      initialState: TestAppState())
    }

    func testSubscribingPostsCurrentState() {
        XCTAssertNil(mockSubscription.receivedInitialState)

        let callbackExpectation = expectation(description: "callbackExpectation")
        mockSubscription.processInitialStateCallback = { state in
            XCTAssertEqual(state, TestAppState(intValue: nil, stringValue: nil))
            callbackExpectation.fulfill()
        }
        store.subscribe(mockSubscription)
        waitForExpectations([callbackExpectation])
    }

    func testStateValueMutationPostsOldState() {
        waitUntil(mockSubscription, subscribesTo: store)

        let callbackExpectation = expectation(description: "callbackExpectation")
        mockSubscription.newStateCallback = { oldState, _ in
            XCTAssertEqual(oldState, TestAppState(intValue: nil, stringValue: nil))
            callbackExpectation.fulfill()
        }
        store.dispatch(SetIntSubstateAction(3))
        waitForExpectations([callbackExpectation])
    }

    func testStateValueMutationPostsNewState() {
        waitUntil(mockSubscription, subscribesTo: store)

        let callbackExpectation = expectation(description: "callbackExpectation")
        mockSubscription.newStateCallback = { _, newState in
            XCTAssertEqual(newState, TestAppState(intValue: 3, stringValue: nil))
            callbackExpectation.fulfill()
        }
        store.dispatch(SetIntSubstateAction(3))
        waitForExpectations([callbackExpectation])
    }

    func testDispatchingFromObserver() {
        mockSubscription.processInitialStateCallback = { _ in
            self.store.dispatch(SetIntSubstateAction(3))
        }

        let callbackExpectation = expectation(description: "callbackExpectation")
        mockSubscription.newStateCallback = { _, newState in
            XCTAssertEqual(newState, TestAppState(intValue: 3, stringValue: nil))
            callbackExpectation.fulfill()
        }

        store.subscribe(mockSubscription)
        waitForExpectations([callbackExpectation])
    }

    func testAddingNewSubscriptionFromObserver() {
        let addedSubscription = MockStoreSubscription<TestAppState>()
        let initialCallbackExpectation = expectation(description: "initialCallbackExpectation")
        addedSubscription.processInitialStateCallback = { _ in initialCallbackExpectation.fulfill() }

        mockSubscription.processInitialStateCallback = { _ in self.store.subscribe(addedSubscription) }
        store.subscribe(mockSubscription)
        waitForExpectations([initialCallbackExpectation])
    }

    func testDuplicateSubscriberReplacesOldSubscription() {
        waitUntil(mockSubscription, subscribesTo: store)

        let newSubscription = MockStoreSubscription<TestAppState>(subscriber: mockSubscriber)
        store.subscribe(newSubscription)

        waitUntilStateUpdates(to: TestAppState(intValue: 3, stringValue: nil),
                              afterDispatching: SetIntSubstateAction(3),
                              andNotifiying: newSubscription,
                              with: store)
        XCTAssertEqual(mockSubscription.receivedStates.count, 0)
    }

    func testSubscriptionsDoNotReceiveUpdatesAfterUnsubscribing() {
        store.subscribe(mockSubscription)

        var updateExpectation = expectation(description: "updateExpectation1")
        mockSubscription.newStateCallback = { _, _ in updateExpectation.fulfill() }
        store.dispatch(SetIntSubstateAction(3))
        waitForExpectations([updateExpectation])

        updateExpectation = expectation(description: "updateExpectation2")
        updateExpectation.isInverted = true
        store.unsubscribe(mockSubscriber)
        store.dispatch(SetIntSubstateAction(5))
        waitForExpectations([updateExpectation])
    }

    func testSubscriptionsWithNilSubscribersDoNotReceiveUpdates() {
        store.subscribe(mockSubscription)

        var updateExpectation = expectation(description: "updateExpectation1")
        mockSubscription.newStateCallback = { _, _ in updateExpectation.fulfill() }
        store.dispatch(SetIntSubstateAction(3))
        waitForExpectations([updateExpectation])

        updateExpectation = expectation(description: "updateExpectation2")
        updateExpectation.isInverted = true
        mockSubscription.subscriber = nil
        store.dispatch(SetIntSubstateAction(5))
        waitForExpectations([updateExpectation])
    }

}
