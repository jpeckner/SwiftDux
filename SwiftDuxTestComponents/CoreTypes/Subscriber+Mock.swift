//
//  Subscriber+Mock.swift
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
import XCTest

public class MockStoreStateSubscriber<StoreState: StateProtocol>: StoreStateSubscriber {

    private(set) public var receivedStates: [StoreState] = []
    public var newStateCallback: ((StoreState) -> Void)?

    public var deinitCallback: (() -> Void)?

    public init() {}

    deinit {
        deinitCallback?()
    }

    public func newState(state: StoreState) {
        receivedStates.append(state)
        newStateCallback?(state)
    }

}

public class MockSubstatesSubscriber<StoreState: StateProtocol>: SubstatesSubscriber {

    public typealias UpdateParams = (newState: StoreState, updatedSubstates: Set<PartialKeyPath<StoreState>>)
    private(set) public var receivedStates: [UpdateParams] = []
    public var newStateCallback: ((StoreState, Set<PartialKeyPath<StoreState>>) -> Void)?

    public var deinitCallback: (() -> Void)?

    public init() {}

    deinit {
        deinitCallback?()
    }

    public func newState(state: StoreState, updatedSubstates: Set<PartialKeyPath<StoreState>>) {
        receivedStates.append((newState: state,
                               updatedSubstates: updatedSubstates))
        newStateCallback?(state, updatedSubstates)
    }

}
