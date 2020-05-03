//
//  EquatableError.swift
//  SwiftDuxExtensions-iOS
//
//  Created by Justin Peckner.
//  Copyright © 2020 Justin Peckner. All rights reserved.
//

import Foundation

public struct EquatableError {
    public let value: Error

    public init(_ value: Error) {
        self.value = value
    }
}

extension EquatableError: Equatable {

    public static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        return true
    }

}
