//
//  StorePerformanceTests.swift
//  SwiftDuxTests
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import SwiftDux
import SwiftDuxTestComponents
import XCTest

class StorePerformanceTests: XCTestCase {

    private typealias Subscriber = MockStoreStateSubscriber<TestAppState>

    private static let numSubscribers = 3000
    private var dispatchQueue: DispatchQueue!
    private var dispatchGroup: DispatchGroup!
    private var subscribers: [Subscriber]!
    private var subscriptions: [StoreStateSubscription<Subscriber>]!
    private var store: Store<TestAppState>!

    override func setUp() {
        super.setUp()

        dispatchQueue = DispatchQueue(label: "StorePerformanceTests")
        dispatchGroup = DispatchGroup()
        subscribers = (0..<StorePerformanceTests.numSubscribers).map { _ in
            let subscriber = Subscriber()
            subscriber.newStateCallback = { _ in self.dispatchGroup.leave() }
            return subscriber
        }
        subscriptions = subscribers.map { StoreStateSubscription(subscriber: $0,
                                                                 dispatchQueue: dispatchQueue) }
        store = Store(reducer: TestAppStateReducer.reduce,
                      initialState: TestAppState())
    }

    func testNotify() {
        subscriptions.forEach { _ in dispatchGroup.enter() }
        subscriptions.forEach { store.subscribe($0) }
        dispatchGroup.wait()

        var value = 0

        measureMetrics([XCTPerformanceMetric.wallClockTime],
                       automaticallyStartMeasuring: false) {
            subscriptions.forEach { _ in dispatchGroup.enter() }
            value += 1

            startMeasuring()
            store.dispatch(SetIntSubstateAction(value))
            dispatchGroup.wait()
            stopMeasuring()
        }
    }

    func testSubscribe() {
        measureMetrics([XCTPerformanceMetric.wallClockTime],
                       automaticallyStartMeasuring: false) {
            subscriptions.forEach { _ in dispatchGroup.enter() }

            startMeasuring()
            subscriptions.forEach { store.subscribe($0) }
            dispatchGroup.wait()
            stopMeasuring()
        }
    }

}
