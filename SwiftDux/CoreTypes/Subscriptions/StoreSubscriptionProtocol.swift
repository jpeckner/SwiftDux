//
//  StoreSubscriptionProtocol.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation

public typealias StateEqualityBlock<State: StateProtocol> = (State, State) -> Bool

public protocol StoreSubscriber: AnyObject {
    associatedtype StoreState: StateProtocol
}

public protocol StoreSubscriptionProtocol {
    associatedtype StoreState: StateProtocol

    var objectIdentifier: ObjectIdentifier { get }

    func processInitialState(newState: StoreState)
    func processUpdateState(oldState: StoreState, newState: StoreState)
    func getSubscriber() -> AnyObject?
}
