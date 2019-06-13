//
//  StoreStateSubscriptionTests.swift
//  SwiftDuxTests
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import SwiftDux
import SwiftDuxTestComponents
import XCTest

class StoreStateSubscriptionTests: XCTestCase {

    private typealias Subscriber = MockStoreStateSubscriber<TestAppState>

    private var dispatchQueue: DispatchQueue!
    private var subscriber: Subscriber!
    private var subscription: StoreStateSubscription<Subscriber>!

    override func setUp() {
        super.setUp()

        dispatchQueue = DispatchQueue(label: "StoreStateSubscriptionTests")
        subscriber = Subscriber()
        subscription = StoreStateSubscription<Subscriber>(subscriber: subscriber,
                                                          dispatchQueue: dispatchQueue)
    }

    func testSubscriberIsNotStronglyReferencedBySubscription() {
        let deinitExpectation = expectation(description: "deinitExpectation")
        subscriber.deinitCallback = { deinitExpectation.fulfill() }
        subscriber = nil
        waitForExpectations([deinitExpectation])
    }

    // MARK: processInitialState()

    func testSubscribedisNotifiedOnProcessingInitialState() {
        XCTAssertTrue(subscriber.receivedStates.isEmpty)
        let initialState = TestAppState()

        subscription.processInitialState(newState: initialState)
        waitForDispatch(dispatchQueue)
        XCTAssertEqual(subscriber.receivedStates.count, 1)
        XCTAssertEqual(subscriber.receivedStates[0], initialState)
    }

    // MARK: processUpdateState()

    func testSubscriberIsNotUpdatedWhenOldStateIsEqualToNewState() {
        XCTAssertTrue(subscriber.receivedStates.isEmpty)
        let oldState = TestAppState()
        let newState = TestAppState(intValue: oldState.intSubstate.value,
                                          stringValue: oldState.stringSubstate.value)

        subscription.processUpdateState(oldState: oldState, newState: newState)
        waitForDispatch(dispatchQueue)
        XCTAssertTrue(subscriber.receivedStates.isEmpty)
    }

    func testSubscriberIsUpdatedWhenOldStateIsNotEqualToNewState() {
        XCTAssertTrue(subscriber.receivedStates.isEmpty)
        let oldState = TestAppState()
        let newState = TestAppState(intValue: (oldState.intSubstate.value ?? 0) + 1,
                                          stringValue: oldState.stringSubstate.value)

        subscription.processUpdateState(oldState: oldState, newState: newState)
        waitForDispatch(dispatchQueue)
        XCTAssertEqual(subscriber.receivedStates.count, 1)
        XCTAssertEqual(subscriber.receivedStates[0], newState)
    }

    // MARK: getSubscriber()

    func testGetSubscriber() {
        XCTAssertTrue(subscription.getSubscriber() === subscriber)
    }

}
