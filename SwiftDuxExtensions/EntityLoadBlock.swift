//
//  EntityLoadBlock.swift
//  SwiftDuxExtensions
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation

public enum EntityLoadBlock<TEntity: Equatable, TError: Error> {
    case nonThrowing((@escaping (Result<TEntity, TError>) -> Void) -> Void)
    case throwing((@escaping (Result<TEntity, TError>) -> Void) throws -> Void)
}
