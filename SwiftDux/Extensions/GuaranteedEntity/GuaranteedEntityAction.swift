//
//  GuaranteedEntityAction.swift
//  SwiftDuxExtensions
//
//  Copyright (c) 2018 Justin Peckner
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

import Foundation

public enum GuaranteedEntityAction<TEntity>: Action {
    case inProgress
    case success(TEntity)
    case failure(EntityError)
}

extension GuaranteedEntityAction: Equatable where TEntity: Equatable {}

// MARK: - GuaranteedEntityActionCreator

public protocol GuaranteedEntityActionCreator {}

public extension GuaranteedEntityActionCreator {

    static func loadGuaranteedEntity<TEntity, TError: Error, TState: StateProtocol>(
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

    private static func dispatchResult<TEntity, TError: Error>(_ result: Result<TEntity, TError>,
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
