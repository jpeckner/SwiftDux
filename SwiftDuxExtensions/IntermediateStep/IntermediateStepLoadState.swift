//
//  IntermediateStepLoadState.swift
//  SwiftDuxExtensions
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation

public enum IntermediateStepLoadState<TError: Error & Equatable>: Equatable {
    case inProgress
    case success
    case failure(TError)
}

public enum IntermediateStepLoadReducer<TError: Error & Equatable> {

    public static func reduce(action: IntermediateStepLoadAction<TError>,
                              currentState: IntermediateStepLoadState<TError>?) -> IntermediateStepLoadState<TError> {
        guard currentState != nil else { return .inProgress }

        switch action {
        case .inProgress:
            return .inProgress
        case .success:
            return .success
        case let .failure(errorBox):
            return .failure(errorBox)
        }
    }

}
