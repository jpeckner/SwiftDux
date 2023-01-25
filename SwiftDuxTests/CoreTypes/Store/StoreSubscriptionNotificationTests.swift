//
//  StoreSubscriptionNotificationTests.swift
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

class StoreSubscriptionNotificationTests: XCTestCase {

    private var mockSubscriber: MockStoreStateSubscriber<TestAppState>!
    private var mockSubscription: MockStoreSubscription<TestAppState>!
    private var store: Store<TestAppAction, TestAppState>!

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
        store.dispatch(.setInt(3))
        waitForExpectations([callbackExpectation])
    }

    func testStateValueMutationPostsNewState() {
        waitUntil(mockSubscription, subscribesTo: store)

        let callbackExpectation = expectation(description: "callbackExpectation")
        mockSubscription.newStateCallback = { _, newState in
            XCTAssertEqual(newState, TestAppState(intValue: 3, stringValue: nil))
            callbackExpectation.fulfill()
        }
        store.dispatch(.setInt(3))
        waitForExpectations([callbackExpectation])
    }

    func testDispatchingFromObserver() {
        mockSubscription.processInitialStateCallback = { _ in
            self.store.dispatch(.setInt(3))
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
                              afterDispatching: .setInt(3),
                              andNotifiying: newSubscription,
                              with: store)
        XCTAssertEqual(mockSubscription.receivedStates.count, 0)
    }

    func testSubscriptionsDoNotReceiveUpdatesAfterUnsubscribing() {
        store.subscribe(mockSubscription)

        var updateExpectation = expectation(description: "updateExpectation1")
        mockSubscription.newStateCallback = { _, _ in updateExpectation.fulfill() }
        store.dispatch(.setInt(3))
        waitForExpectations([updateExpectation])

        updateExpectation = expectation(description: "updateExpectation2")
        updateExpectation.isInverted = true
        store.unsubscribe(mockSubscriber)
        store.dispatch(.setInt(5))
        waitForExpectations([updateExpectation])
    }

    func testSubscriptionsWithNilSubscribersDoNotReceiveUpdates() {
        store.subscribe(mockSubscription)

        var updateExpectation = expectation(description: "updateExpectation1")
        mockSubscription.newStateCallback = { _, _ in updateExpectation.fulfill() }
        store.dispatch(.setInt(3))
        waitForExpectations([updateExpectation])

        updateExpectation = expectation(description: "updateExpectation2")
        updateExpectation.isInverted = true
        mockSubscription.subscriber = nil
        store.dispatch(.setInt(5))
        waitForExpectations([updateExpectation])
    }

}
