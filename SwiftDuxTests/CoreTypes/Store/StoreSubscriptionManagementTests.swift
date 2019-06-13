//
//  StoreSubscriptionManagementTests.swift
//  SwiftDuxTests
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

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
