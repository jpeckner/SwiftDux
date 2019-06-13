//
//  Middleware.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

public typealias Middleware<State: StateProtocol> =
    (@escaping DispatchFunction, @escaping (@escaping StateReceiverBlock<State>) -> Void)
    -> (@escaping DispatchFunction)
    -> DispatchFunction

func asyncActionMiddleware<State: StateProtocol>() -> Middleware<State> {
    return { dispatch, stateReceiverBlock in
        return { next in
            return { action in
                guard let asyncAction = action as? AsyncAction<State> else {
                    next(action)
                    return
                }

                asyncAction.thunk(dispatch, stateReceiverBlock)
            }
        }
    }
}
