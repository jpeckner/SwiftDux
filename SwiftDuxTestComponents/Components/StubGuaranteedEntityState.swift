//
//  StubGuaranteedEntityState.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2020 Justin Peckner. All rights reserved.
//

import Foundation
import SwiftDuxExtensions

public struct StubGuaranteedEntityState: GuaranteedEntityState, Equatable {
    public typealias TEntity = StubEntity
    public static let fallbackValue = StubEntity(stringValue: "FallbackValue",
                                                 intValue: 10,
                                                 doubleValue: 20.0)

    public let loadState: GuaranteedEntityLoadState<TEntity>

    public init(loadState: GuaranteedEntityLoadState<TEntity>) {
        self.loadState = loadState
    }
}

public typealias StubGuaranteedEntityReducer = GuaranteedEntityReducer<StubGuaranteedEntityState>
