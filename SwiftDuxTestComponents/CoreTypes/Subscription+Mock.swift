//
//  Subscription+Mock.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation
import SwiftDux
import XCTest

public class MockStoreSubscription<State: StateProtocol>: StoreSubscriptionProtocol {

    public var subscriber: AnyObject?
    public let objectIdentifier: ObjectIdentifier

    private(set) public var receivedInitialState: State?
    public var processInitialStateCallback: ((State) -> Void)?

    public typealias UpdateParams = (oldState: State, newState: State)
    private(set) public var receivedStates: [UpdateParams] = []
    public var newStateCallback: ((State, State) -> Void)?

    public var deinitCallback: (() -> Void)?

    public init(subscriber: AnyObject = NSObject()) {
        self.subscriber = subscriber
        self.objectIdentifier = ObjectIdentifier(subscriber)
    }

    deinit {
        deinitCallback?()
    }

    public func processInitialState(newState: State) {
        XCTAssertNil(receivedInitialState, "processInitialState() should be called only once")

        receivedInitialState = newState
        processInitialStateCallback?(newState)
    }

    public func processUpdateState(oldState: State, newState: State) {
        receivedStates.append((oldState, newState))
        newStateCallback?(oldState, newState)
    }

    public func getSubscriber() -> AnyObject? {
        return subscriber
    }

}

extension XCTestCase {

    public func waitUntil<StoreState: StateProtocol>(_ subscription: MockStoreSubscription<StoreState>,
                                                     subscribesTo store: Store<StoreState>,
                                                     timeout: TimeInterval = defaultWaitTime) {
        let callbackExpectation = expectation(description: "callbackExpectation")
        subscription.processInitialStateCallback = { _ in callbackExpectation.fulfill() }

        store.subscribe(subscription)
        waitForExpectations([callbackExpectation], withTimeout: timeout)
    }

    public func waitUntilStateUpdates<StoreState: StateProtocol>(
        to expectedValue: StoreState,
        afterDispatching action: Action,
        andNotifiying subscription: MockStoreSubscription<StoreState>,
        with store: Store<StoreState>,
        timeout: TimeInterval = defaultWaitTime,
        file: StaticString = #file,
        line: UInt = #line
    ) where StoreState: Equatable {
        let callbackExpectation = expectation(description: "callbackExpectation")
        subscription.newStateCallback = { _, newState in
            XCTAssertEqual(newState, expectedValue,
                           file: file,
                           line: line)
            callbackExpectation.fulfill()
        }

        store.dispatch(action)
        waitForExpectations([callbackExpectation], withTimeout: timeout)
    }

}
