//
//  Subscriber+Mock.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

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
