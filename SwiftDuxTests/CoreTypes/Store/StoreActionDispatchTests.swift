//
//  StoreActionDispatchTests.swift
//  SwiftDuxTests
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import SwiftDux
import SwiftDuxTestComponents
import XCTest

class StoreActionDispatchTests: XCTestCase {

    private var mockSubscription: MockStoreSubscription<TestAppState>!
    private var store: Store<TestAppState>!

    override func setUp() {
        super.setUp()

        mockSubscription = MockStoreSubscription()
        store = Store(reducer: TestAppStateReducer.reduce,
                      initialState: TestAppState())

        waitUntil(mockSubscription, subscribesTo: store)
        XCTAssertEqual(mockSubscription.receivedInitialState, TestAppState(intValue: nil,
                                                                                 stringValue: nil))
    }

    func testDispatchingPlainAction() {
        let action = SetIntSubstateAction(5)

        waitUntilStateUpdates(to: TestAppState(intValue: 5, stringValue: nil),
                              afterDispatching: action,
                              andNotifiying: mockSubscription,
                              with: store)
    }

    func testDispatchingAsyncAction() {
        let asyncAction = AsyncAction<TestAppState> { dispatch, _ in
            dispatch(SetIntSubstateAction(5))
        }

        waitUntilStateUpdates(to: TestAppState(intValue: 5, stringValue: nil),
                              afterDispatching: asyncAction,
                              andNotifiying: mockSubscription,
                              with: store)
    }

    func testDispatchingAsyncActionWithDelayedDispatch() {
        let asyncAction = AsyncAction<TestAppState> { dispatch, _ in
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 0.1) {
                dispatch(SetIntSubstateAction(5))
            }
        }

        waitUntilStateUpdates(to: TestAppState(intValue: 5, stringValue: nil),
                              afterDispatching: asyncAction,
                              andNotifiying: mockSubscription,
                              with: store,
                              timeout: 0.2)
    }

}
