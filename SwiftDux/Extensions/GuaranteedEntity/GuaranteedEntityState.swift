//
//  GuaranteedEntityState.swift
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

// MARK: GuaranteedEntityLoadState

public enum GuaranteedEntityLoadState<TEntity: Equatable>: Action, Equatable {
    case idle
    case inProgress
    case success(TEntity)
    case failure(EntityError)
}

// MARK: GuaranteedEntityState

public protocol GuaranteedEntityState {
    associatedtype TEntity: Equatable

    static var fallbackValue: TEntity { get }

    init(loadState: GuaranteedEntityLoadState<TEntity>)
    var loadState: GuaranteedEntityLoadState<TEntity> { get }
}

public extension GuaranteedEntityState {

    init() {
        self.init(loadState: .idle)
    }

    var currentValue: TEntity {
        switch loadState {
        case let .success(entity):
            return entity
        case .idle, .inProgress, .failure:
            return Self.fallbackValue
        }
    }

    var hasCompletedLoading: Bool {
        switch loadState {
        case .idle, .inProgress:
            return false
        case .success, .failure:
            return true
        }
    }

}

// MARK: GuaranteedEntityReducer

public enum GuaranteedEntityReducer<State: GuaranteedEntityState> {

    public static func reduce(action: Action, currentState: State) -> State {
        guard let entityAction = action as? GuaranteedEntityAction<State.TEntity> else { return currentState }

        switch entityAction {
        case .inProgress:
            return State(loadState: .inProgress)
        case let .success(entity):
            return State(loadState: .success(entity))
        case let .failure(entityError):
            return State(loadState: .failure(entityError))
        }
    }

}
