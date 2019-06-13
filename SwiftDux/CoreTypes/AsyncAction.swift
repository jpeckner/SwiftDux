//
//  AsyncAction.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

public typealias DispatchFunction = (Action) -> Void

public typealias StateReceiverBlock<State: StateProtocol> = (State) -> Void

public typealias Thunk<State: StateProtocol> = (
    @escaping DispatchFunction,
    (@escaping StateReceiverBlock<State>) -> Void
) -> Void

public struct AsyncAction<State: StateProtocol>: Action {
    public let thunk: Thunk<State>

    public init(thunk: @escaping Thunk<State>) {
        self.thunk = thunk
    }
}
