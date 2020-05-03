//
//  EntityState.swift
//  SwiftDuxExtensions
//
//  Created by Justin Peckner.
//  Copyright © 2018 Justin Peckner. All rights reserved.
//

import Foundation
import SwiftDux

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
