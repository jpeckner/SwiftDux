//
//  EntityError.swift
//  SwiftDuxExtensions-iOS
//
//  Created by Justin Peckner.
//  Copyright © 2020 Justin Peckner. All rights reserved.
//

import Foundation

public enum EntityError: Error, Equatable {
    case preloadError(underlyingError: EquatableError)
    case loadError(underlyingError: EquatableError)
}
