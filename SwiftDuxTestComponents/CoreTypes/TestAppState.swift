//
//  State+Stub.swift
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
