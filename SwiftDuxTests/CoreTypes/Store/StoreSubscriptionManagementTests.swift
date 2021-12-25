//
//  StoreSubscriptionManagementTests.swift
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

class StoreSubscriptionManagementTests: XCTestCase {

    private var store: Store<TestAppState>!

    override func setUp() {
        super.setUp()

        store = Store(reducer: TestAppStateReducer.reduce,
                      initialState: TestAppState())
    }

    func testSubscriberIsNotStronglyReferencedByStore() {
        let deinitExpectation = expectation(description: "deinitExpectation")
        var subscriber: MockStoreStateSubscriber<TestAppState>! = .init()
        subscriber.deinitCallback = { deinitExpectation.fulfill() }

        store.subscribe(subscriber)
        subscriber = nil
        waitForExpectations([deinitExpectation])
    }

    func testSubscriptionsWithNilSubscribersAreDeallocatedOnStateUpdate() {
        var subscription: MockStoreSubscription<TestAppState>! = .init()
        waitUntil(subscription, subscribesTo: store)

        let deinitExpectation = expectation(description: "deinitExpectation")
        subscription.deinitCallback = { deinitExpectation.fulfill() }
        subscription.subscriber = nil
        subscription = nil
        store.dispatch(SetIntSubstateAction(5))
        waitForExpectations([deinitExpectation])
    }

}
