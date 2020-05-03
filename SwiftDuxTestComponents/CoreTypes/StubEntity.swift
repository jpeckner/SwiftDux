//
//  StubEntity.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2018 Justin Peckner. All rights reserved.
//

import Foundation

public struct StubEntity: Equatable {
    public let stringValue: String
    public let intValue: Int
    public let doubleValue: Double

    public init(stringValue: String,
                intValue: Int,
                doubleValue: Double) {
        self.stringValue = stringValue
        self.intValue = intValue
        self.doubleValue = doubleValue
    }
}

public extension StubEntity {

    static func stubValue() -> StubEntity {
        return StubEntity(stringValue: "ABCDEFG",
                          intValue: 100,
                          doubleValue: 1.5)
    }

}
