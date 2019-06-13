//
//  State+Stub.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import SwiftDux

public struct TestAppState: StateProtocol, Equatable {
    public let intSubstate: TestIntSubstate
    public let stringSubstate: TestStringSubstate

    public struct TestIntSubstate: Equatable {
        public let value: Int?
    }

    public struct TestStringSubstate: Equatable {
        public let value: String?
    }
}

public extension TestAppState {

    init() {
        self.intSubstate = TestIntSubstate(value: nil)
        self.stringSubstate = TestStringSubstate(value: nil)
    }

    init(intValue: Int?,
         stringValue: String?) {
        self.intSubstate = TestIntSubstate(value: intValue)
        self.stringSubstate = TestStringSubstate(value: stringValue)
    }

}

public enum TestAppStateReducer {

    public static func reduce(action: Action, state: TestAppState) -> TestAppState {
        let intSubstate = intSubstateReducer(action: action, state: state.intSubstate)
        let stringSubstate = stringSubstateReducer(action: action, state: state.stringSubstate)
        return TestAppState(intSubstate: intSubstate, stringSubstate: stringSubstate)
    }

    private static func intSubstateReducer(action: Action, state: TestAppState.TestIntSubstate)
        -> TestAppState.TestIntSubstate {
        switch action {
        case let action as SetIntSubstateAction:
            return TestAppState.TestIntSubstate(value: action.value)
        default:
            return state
        }
    }

    private static func stringSubstateReducer(action: Action, state: TestAppState.TestStringSubstate)
        -> TestAppState.TestStringSubstate {
        switch action {
        case let action as SetStringSubstateAction:
            return TestAppState.TestStringSubstate(value: action.value)
        default:
            return state
        }
    }

}
