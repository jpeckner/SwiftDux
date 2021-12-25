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

public enum EntityLoadState<TEntity: Equatable>: Equatable {
    case idle
    case inProgress
    case success(TEntity)
    case failure(EntityError)
}

// MARK: EntityState

public struct EntityState<TEntity: Equatable>: Equatable {
    public let loadState: EntityLoadState<TEntity>
    public let currentValue: TEntity?

    public init(loadState: EntityLoadState<TEntity>,
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

// MARK: EntityReducer

public enum EntityReducer<TEntity: Equatable> {

    public static func reduce(action: Action,
                              currentState: EntityState<TEntity>) -> EntityState<TEntity> {
        guard let entityAction = action as? EntityAction<TEntity> else {
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
