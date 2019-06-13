//
//  EquatableKeyPath.swift
//  SwiftDux-iOS
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation

/// EquatableKeyPath acts as a type-eraser around a keypath of StoreState; it hides the exact type returned by the path,
/// while providing an equality block for comparing two of the path's values.
public struct EquatableKeyPath<StoreState: StateProtocol> {

    public let keyPath: PartialKeyPath<StoreState>
    public let equalityBlock: StateEqualityBlock<StoreState>

    public init<E: Equatable>(_ keyPath: KeyPath<StoreState, E>) {
        self.keyPath = keyPath
        self.equalityBlock = { $0[keyPath: keyPath] == $1[keyPath: keyPath] }
    }

}

extension EquatableKeyPath: Hashable {

    public static func == (lhs: EquatableKeyPath<StoreState>, rhs: EquatableKeyPath<StoreState>) -> Bool {
        return lhs.keyPath == rhs.keyPath
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(keyPath)
    }

}
