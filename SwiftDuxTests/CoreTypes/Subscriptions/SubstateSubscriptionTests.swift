//
//  SubstateSubscriptionTests.swift
//  SwiftDux-Tests
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
