//
//  EntityState.swift
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

// MARK: LoadState

public enum EntityLoadState<TEntity, TError: Error> {
    case idle
    case inProgress
    case success(TEntity)
    case failure(TError)
}

extension EntityLoadState: Equatable where TEntity: Equatable, TError: Equatable {}

extension EntityLoadState: Sendable where TEntity: Sendable {}

// MARK: - EntityState

public struct EntityState<TEntity, TError: Error> {
    public let loadState: EntityLoadState<TEntity, TError>
    public let currentValue: TEntity?

    public init(loadState: EntityLoadState<TEntity, TError>,
                currentValue: TEntity?) {
        self.loadState = loadState
        self.currentValue = currentValue
    }
}

public extension EntityState {

    init() {
        self.loadState = .idle
        self.currentValue = nil
    }

}

extension EntityState: Equatable where TEntity: Equatable, TError: Equatable {}

// MARK: - EntityReducer

public enum EntityReducer<TEntity, TError: Error> {

    public static func reduce(action: Action,
                              currentState: EntityState<TEntity, TError>) -> EntityState<TEntity, TError> {
        guard let entityAction = action as? EntityAction<TEntity, TError> else {
            return currentState
        }

        switch entityAction {
        case .idle:
            return EntityState(loadState: .idle,
                               currentValue: currentState.currentValue)
        case .inProgress:
            return EntityState(loadState: .inProgress,
                               currentValue: currentState.currentValue)
        case let .success(entity):
            return EntityState(loadState: .success(entity),
                               currentValue: entity)
        case let .failure(entityError):
            return EntityState(loadState: .failure(entityError),
                               currentValue: currentState.currentValue)
        }
    }

}
