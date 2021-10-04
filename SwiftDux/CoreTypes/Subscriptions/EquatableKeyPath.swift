//
//  EquatableKeyPath.swift
//  SwiftDux-iOS
//
//  Copyright (c) 2019 Justin Peckner
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
