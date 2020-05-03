//
//  EntityAction.swift
//  SwiftDuxExtensions
//
//  Created by Justin Peckner.
//  Copyright © 2018 Justin Peckner. All rights reserved.
//

import Foundation
import SwiftDux

public enum EntityAction<TEntity: Equatable>: Action, Equatable {
    case idle
    case inProgress
    case success(TEntity)
    case failure(EntityError)
}

public protocol EntityActionCreator {}

public extension EntityActionCreator {

    static func loadEntity<TEntity: Equatable, TError: Error, TState: StateProtocol>(
        _ loadBlock: EntityLoadBlock<TEntity, TError>
    ) -> AsyncAction<TState> {
        return AsyncAction<TState> { dispatch, _ in
            dispatch(EntityAction<TEntity>.inProgress)

            switch loadBlock {
            case let .nonThrowing(block):
                block { taskResult in
                    dispatchTaskResult(taskResult: taskResult, dispatch: dispatch)
                }
            case let .throwing(block):
                do {
                    try block { taskResult in
                        dispatchTaskResult(taskResult: taskResult, dispatch: dispatch)
                    }
                } catch {
                    let entityError = EntityError.preloadError(underlyingError: EquatableError(error))
                    dispatch(EntityAction<TEntity>.failure(entityError))
                }
            }
        }
    }

    private static func dispatchTaskResult<TEntity: Equatable, TError: Error>(taskResult: Result<TEntity, TError>,
                                                                              dispatch: DispatchFunction) {
        switch taskResult {
        case let .success(entity):
            dispatch(EntityAction<TEntity>.success(entity))
        case let .failure(error):
            let entityError = EntityError.loadError(underlyingError: EquatableError(error))
            dispatch(EntityAction<TEntity>.failure(entityError))
        }
    }

}
