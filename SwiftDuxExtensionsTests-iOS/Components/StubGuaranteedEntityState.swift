//
//  StubGuaranteedEntityState.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2020 Justin Peckner. All rights reserved.
//

import Foundation
import SwiftDuxExtensions
import SwiftDuxTestComponents

struct StubGuaranteedEntityState: GuaranteedEntityState, Equatable {
    typealias TEntity = StubEntity
    static let fallbackValue = StubEntity(stringValue: "FallbackValue",
                                          intValue: 10,
                                          doubleValue: 20.0)

    let loadState: GuaranteedEntityLoadState<TEntity>

    init(loadState: GuaranteedEntityLoadState<TEntity>) {
        self.loadState = loadState
    }
}

typealias StubGuaranteedEntityReducer = GuaranteedEntityReducer<StubGuaranteedEntityState>
