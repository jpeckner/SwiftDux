//
//  Subscription+Mock.swift
//  SwiftDuxTestComponents
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

    public func waitUntil<TAction: Action, TState: StateProtocol>(
        _ subscription: MockStoreSubscription<TState>,
        subscribesTo store: Store<TAction, TState>,
        timeout: TimeInterval = defaultWaitTime
    ) {
        let callbackExpectation = expectation(description: "callbackExpectation")
        subscription.processInitialStateCallback = { _ in callbackExpectation.fulfill() }

        store.subscribe(subscription)
        waitForExpectations([callbackExpectation], withTimeout: timeout)
    }

    public func waitUntilStateUpdates<TAction: Action, TState: StateProtocol>(
        to expectedValue: TState,
        afterDispatching action: TAction,
        andNotifiying subscription: MockStoreSubscription<TState>,
        with store: Store<TAction, TState>,
        timeout: TimeInterval = defaultWaitTime,
        file: StaticString = #file,
        line: UInt = #line
    ) where TState: Equatable {
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
