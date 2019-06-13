//
//  StoreMiddlewareTests.swift
//  SwiftDuxTests
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import SwiftDux
import SwiftDuxTestComponents
import XCTest

let firstMiddleware: Middleware<TestAppState> = { _, _ in
    return { next in
        return { action in
            guard let stringAction = action as? SetStringSubstateAction,
                let value = stringAction.value
            else {
                next(action)
                return
            }

            let updatedAction = SetStringSubstateAction(value + " First Middleware")
            next(updatedAction)
        }
    }
}

let secondMiddleware: Middleware<TestAppState> = { _, _ in
    return { next in
        return { action in
            guard let stringAction = action as? SetStringSubstateAction,
                let value = stringAction.value
            else {
                next(action)
                return
            }

            let updatedAction = SetStringSubstateAction(value + " Second Middleware")
            next(updatedAction)
        }
    }
}

let dispatchingMiddleware: Middleware<TestAppState> = { dispatch, _ in
    return { next in
        return { action in
            guard let intAction = action as? SetIntSubstateAction else {
                next(action)
                return
            }

            dispatch(SetStringSubstateAction("\(intAction.value ?? 0)"))
        }
    }
}

func stateAccessMiddleware(_ expectedStateValue: TestAppState,
                           expectationToFulfill: XCTestExpectation) -> Middleware<TestAppState> {
    return { dispatch, stateReceiverBlock in
        return { next in
            return { action in
                stateReceiverBlock { appState in
                    guard expectedStateValue == appState else {
                        XCTFail("Unexpected state value: \(appState)")
                        return
                    }

                    expectationToFulfill.fulfill()
                }
            }
        }
    }
}

let dispatchFromStateBlockMiddleware: Middleware<TestAppState> = { dispatch, stateReceiverBlock in
    return { next in
        return { action in
            stateReceiverBlock { appState in
                guard let stringAction = action as? SetStringSubstateAction,
                    stringAction.value == "Start"
                else {
                    next(action)
                    return
                }

                // dispatch a new action
                let previousStringValue = appState.stringSubstate.value ?? ""
                dispatch(SetStringSubstateAction("Finish \(previousStringValue)"))
            }
        }
    }
}

class StoreMiddlewareTests: XCTestCase {

    var verificationSubscription: MockStoreSubscription<TestAppState>!

    override func setUp() {
        super.setUp()

        verificationSubscription = MockStoreSubscription()
    }

    func testMiddlewaresAreChainedInOrderPassedToStore() {
        let store = Store<TestAppState>(
            reducer: TestAppStateReducer.reduce,
            initialState: TestAppState(),
            middleware: [
                firstMiddleware,
                secondMiddleware
            ]
        )
        store.subscribe(verificationSubscription)

        let expectedState = TestAppState(intValue: nil,
                                               stringValue: "OK First Middleware Second Middleware")
        waitUntilStateUpdates(to: expectedState,
                              afterDispatching: SetStringSubstateAction("OK"),
                              andNotifiying: verificationSubscription,
                              with: store)
    }

    func testMiddlewareCanAccessState() {
        let initialState = TestAppState(intValue: nil, stringValue: "My initial value")
        let expectationToFulfill = XCTestExpectation(description: "stateAccessMiddleware")
        let middleware = stateAccessMiddleware(initialState,
                                               expectationToFulfill: expectationToFulfill)

        let store = Store<TestAppState>(
            reducer: TestAppStateReducer.reduce,
            initialState: initialState,
            middleware: [middleware]
        )
        store.dispatch(NoOpAction())
        waitForExpectations([expectationToFulfill])
    }

    func testMiddlewareCanDispatch() {
        let store = Store<TestAppState>(
            reducer: TestAppStateReducer.reduce,
            initialState: TestAppState(),
            middleware: [
                firstMiddleware,
                secondMiddleware,
                dispatchingMiddleware
            ]
        )
        store.subscribe(verificationSubscription)

        let expectedState = TestAppState(intValue: nil,
                                               stringValue: "10 First Middleware Second Middleware")
        waitUntilStateUpdates(to: expectedState,
                              afterDispatching: SetIntSubstateAction(10),
                              andNotifiying: verificationSubscription,
                              with: store)
    }

    func testMiddlewareCanDispatchFromStateReceiverBlock() {
        let store = Store<TestAppState>(
            reducer: TestAppStateReducer.reduce,
            initialState: TestAppState(),
            middleware: [dispatchFromStateBlockMiddleware]
        )
        store.subscribe(verificationSubscription)

        let randomInitialValue = String(arc4random() % 10000)
        waitUntilStateUpdates(to: TestAppState(intValue: nil,
                                                     stringValue: randomInitialValue),
                              afterDispatching: SetStringSubstateAction(randomInitialValue),
                              andNotifiying: verificationSubscription,
                              with: store)

        let expectedState = TestAppState(intValue: nil,
                                               stringValue: "Finish \(randomInitialValue)")
        waitUntilStateUpdates(to: expectedState,
                              afterDispatching: SetStringSubstateAction("Start"),
                              andNotifiying: verificationSubscription,
                              with: store)
    }

    func testMiddlewareCanCallNextFromStateReceiverBlock() {
        let store = Store<TestAppState>(
            reducer: TestAppStateReducer.reduce,
            initialState: TestAppState(),
            middleware: [
                dispatchFromStateBlockMiddleware,
                firstMiddleware,
                secondMiddleware,
            ]
        )
        store.subscribe(verificationSubscription)

        let expectedState = TestAppState(intValue: nil,
                                               stringValue: "Don't start First Middleware Second Middleware")
        waitUntilStateUpdates(to: expectedState,
                              afterDispatching: SetStringSubstateAction("Don't start"),
                              andNotifiying: verificationSubscription,
                              with: store)
    }

}
