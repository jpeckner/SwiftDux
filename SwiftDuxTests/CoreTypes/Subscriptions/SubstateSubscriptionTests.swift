//
//  SubstateSubscriptionTests.swift
//  SwiftDux-Tests
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import SwiftDux
import SwiftDuxTestComponents
import XCTest

class SubstateSubscriptionTests: XCTestCase {

    private typealias Subscriber = MockSubstatesSubscriber<TestAppState>

    private var dispatchQueue: DispatchQueue!
    private var subscriber: Subscriber!
    private var subscription: SubstatesSubscription<Subscriber>!

    override func setUp() {
        super.setUp()

        dispatchQueue = DispatchQueue(label: "SubstateSubscriptionTests")
        subscriber = Subscriber()
        subscription = SubstatesSubscription<Subscriber>(
            subscriber: subscriber,
            equatableKeyPaths: [
                EquatableKeyPath(\TestAppState.intSubstate),
                EquatableKeyPath(\TestAppState.stringSubstate),
            ],
            dispatchQueue: dispatchQueue
        )
    }

    // MARK: Tests

    func testSubscriberIsNotStronglyReferencedBySubscription() {
        let deinitExpectation = expectation(description: "deinitExpectation")
        subscriber.deinitCallback = { deinitExpectation.fulfill() }
        subscriber = nil
        waitForExpectations([deinitExpectation])
    }

    // MARK: processInitialState()

    func testSubscriberIsNotifiedForAllSubstatesOnProcessingInitialState() {
        let initialState = TestAppState()
        let updateExpectation = expectation(description: "updateExpectation")
        subscriber.newStateCallback = { state, updatedSubstates in
            XCTAssertEqual(state, initialState)
            XCTAssertEqual(updatedSubstates, [\TestAppState.intSubstate,
                                              \TestAppState.stringSubstate])
            updateExpectation.fulfill()
        }

        subscription.processInitialState(newState: initialState)
        waitForExpectations([updateExpectation])
    }

    // MARK: processUpdateState()

    func testSubscriberIsNotUpdatedWhenNoSubscribedSubstateChanges() {
        XCTAssertTrue(subscriber.receivedStates.isEmpty)
        let oldState = TestAppState()
        let newState = TestAppState(intValue: oldState.intSubstate.value,
                                          stringValue: oldState.stringSubstate.value)

        subscription.processUpdateState(oldState: oldState, newState: newState)
        waitForDispatch(dispatchQueue)
        XCTAssertTrue(subscriber.receivedStates.isEmpty)
    }

    func testSubscriberIsNotUpdatedWhenUnsubscribedSubstatesChange() {
        XCTAssertTrue(subscriber.receivedStates.isEmpty)
        let oldState = TestAppState()
        let newState = TestAppState(intValue: oldState.intSubstate.value,
                                          stringValue: (oldState.stringSubstate.value ?? "") + " new stuff")

        subscription = SubstatesSubscription<Subscriber>(
            subscriber: subscriber,
            equatableKeyPaths: [
                EquatableKeyPath(\TestAppState.intSubstate),
            ],
            dispatchQueue: dispatchQueue
        )

        subscription.processUpdateState(oldState: oldState, newState: newState)
        waitForDispatch(dispatchQueue)
        XCTAssertTrue(subscriber.receivedStates.isEmpty)
    }

    func testSubscriberIsUpdatedWhenOneSubstateChanges() {
        let oldState = TestAppState()
        let newState = TestAppState(intValue: (oldState.intSubstate.value ?? 0) + 1,
                                          stringValue: oldState.stringSubstate.value)

        let updateExpectation = expectation(description: "updateExpectation")
        subscriber.newStateCallback = { state, updatedSubstates in
            XCTAssertEqual(state, newState)
            XCTAssertEqual(updatedSubstates, [\TestAppState.intSubstate])
            updateExpectation.fulfill()
        }

        subscription.processUpdateState(oldState: oldState, newState: newState)
        waitForExpectations([updateExpectation])
    }

    func testSubscriberIsUpdatedWhenMultipleSubstatesChange() {
        let oldState = TestAppState()
        let newState = TestAppState(intValue: (oldState.intSubstate.value ?? 0) + 1,
                                          stringValue: (oldState.stringSubstate.value ?? "") + " new stuff")

        let updateExpectation = expectation(description: "updateExpectation")
        subscriber.newStateCallback = { state, updatedSubstates in
            XCTAssertEqual(state, newState)
            XCTAssertEqual(updatedSubstates, [\TestAppState.intSubstate,
                                              \TestAppState.stringSubstate])
            updateExpectation.fulfill()
        }

        subscription.processUpdateState(oldState: oldState, newState: newState)
        waitForExpectations([updateExpectation])
    }

    // MARK: getSubscriber()

    func testGetSubscriber() {
        XCTAssertTrue(subscription.getSubscriber() === subscriber)
    }

}
