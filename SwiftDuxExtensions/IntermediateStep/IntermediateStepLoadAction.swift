//
//  IntermediateStepLoadAction.swift
//  SwiftDuxExtensions
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation
import SwiftDux

public enum IntermediateStepLoadAction<TError: Error & Equatable>: Action, Equatable {
    case inProgress
    case success
    case failure(TError)
}
