//
//  StoreStateSubscriptionTests.swift
//  SwiftDuxTests
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
