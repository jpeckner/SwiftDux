//
//  StubGuaranteedEntityState.swift
//  SwiftDuxTestComponents
//
//  Copyright (c) 2020 Justin Peckner
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

import SwiftDux

public struct StubGuaranteedEntityState<TError: Error>: GuaranteedEntityState {
    public typealias TEntity = StubEntity

    public static var fallbackValue: StubEntity {
        StubEntity(stringValue: "FallbackValue",
                   intValue: 10,
                   doubleValue: 20.0)
    }

    public let loadState: GuaranteedEntityLoadState<TEntity, TError>

    public init(loadState: GuaranteedEntityLoadState<TEntity, TError>) {
        self.loadState = loadState
    }
}

extension StubGuaranteedEntityState: Equatable where TError: Equatable {}

public typealias StubGuaranteedEntityReducer<TError: Error> = GuaranteedEntityReducer<StubGuaranteedEntityState<TError>>
