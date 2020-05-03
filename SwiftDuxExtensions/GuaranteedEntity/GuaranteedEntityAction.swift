//
//  GuaranteedEntityAction.swift
//  SwiftDuxExtensions
//
//  Created by Justin Peckner.
//  Copyright © 2018 Justin Peckner. All rights reserved.
//

import Foundation
import SwiftDux

public enum GuaranteedEntityAction<TEntity: Equatable>: Action, Equatable {
    case inProgress
    case success(TEntity)
    case failure(EntityError)
}

public protocol GuaranteedEntityActionCreator {}

public extension GuaranteedEntityActionCreator {

    static func loadGuaranteedEntity<TEntity: Equatable, TError: Error, TState: StateProtocol>(
        _ loadBlock: EntityLoadBlock<TEntity, TError>
    ) -> AsyncAction<TState> {
        return AsyncAction<TState> { dispatch, _ in
            dispatch(GuaranteedEntityAction<TEntity>.inProgress)

            switch loadBlock {
            case let .nonThrowing(block):
                block { result in
                    dispatchResult(result,
                                   dispatch: dispatch)
                }
            case let .throwing(block):
                do {
                    try block { result in
                        dispatchResult(result,
                                       dispatch: dispatch)
                    }
                } catch {
                    let entityError = EntityError.preloadError(underlyingError: EquatableError(error))
                    dispatch(GuaranteedEntityAction<TEntity>.failure(entityError))
                }
            }
        }
    }

    private static func dispatchResult<TEntity: Equatable, TError: Error>(_ result: Result<TEntity, TError>,
                                                                          dispatch: DispatchFunction) {
        switch result {
        case let .success(entity):
            dispatch(GuaranteedEntityAction<TEntity>.success(entity))
        case let .failure(error):
            let entityError = EntityError.loadError(underlyingError: EquatableError(error))
            dispatch(GuaranteedEntityAction<TEntity>.failure(entityError))
        }
    }

}
