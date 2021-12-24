//
//  EntityReducerTests.swift
//  SwiftDuxExtensionsTests
//
//  Copyright (c) 2018 Justin Peckner
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

import Nimble
import Quick
import SwiftDuxExtensions
import SwiftDuxTestComponents

class EntityReducerTests: QuickSpec {

    // swiftlint:disable function_body_length
    // swiftlint:disable implicitly_unwrapped_optional
    override func spec() {

        describe("reduce") {

            let stubEntity = StubEntity.stubValue()

            context("when the action is not an EntityAction") {
                let currentState = EntityState<StubEntity>(loadState: .inProgress,
                                                           currentValue: nil)

                var resultState: EntityState<StubEntity>!

                beforeEach {
                    resultState = EntityReducer.reduce(action: StubAction.genericAction,
                                                       currentState: currentState)
                }

                it("returns the current state") {
                    expect(resultState) == currentState
                }
            }

            context("when the action is .idle") {
                let currentState = EntityState<StubEntity>(loadState: .inProgress,
                                                           currentValue: stubEntity)

                var resultState: EntityState<StubEntity>!

                beforeEach {
                    resultState = EntityReducer.reduce(action: EntityAction<StubEntity>.idle,
                                                       currentState: currentState)
                }

                it("returns the .idle loadState") {
                    expect(resultState.loadState) == .idle
                }

                it("returns the currentValue held previously") {
                    expect(resultState.currentValue) == stubEntity
                }
            }

            context("when the action is .inProgress") {
                let currentState = EntityState<StubEntity>(loadState: .idle,
                                                           currentValue: stubEntity)

                var resultState: EntityState<StubEntity>!

                beforeEach {
                    resultState = EntityReducer.reduce(action: EntityAction<StubEntity>.inProgress,
                                                       currentState: currentState)
                }

                it("returns the .inProgress loadState") {
                    expect(resultState.loadState) == .inProgress
                }

                it("returns the currentValue held previously") {
                    expect(resultState.currentValue) == stubEntity
                }
            }

            context("when the action is .success") {
                let currentState = EntityState<StubEntity>(loadState: .inProgress,
                                                           currentValue: stubEntity)
                let newValue = StubEntity(stringValue: "XYZ",
                                          intValue: 200,
                                          doubleValue: 7.5)

                var resultState: EntityState<StubEntity>!

                beforeEach {
                    resultState = EntityReducer.reduce(action: EntityAction<StubEntity>.success(newValue),
                                                       currentState: currentState)
                }

                it("returns the .success loadState") {
                    expect(resultState.loadState) == .success(newValue)
                }

                it("returns the new entity as currentValue") {
                    expect(resultState.currentValue) == newValue
                }
            }

            context("when the action is .failure") {
                let currentState = EntityState<StubEntity>(loadState: .inProgress,
                                                           currentValue: stubEntity)
                let entityError = EntityError.loadError(underlyingError: EquatableError(StubError.plainError))

                var resultState: EntityState<StubEntity>!

                beforeEach {
                    resultState = EntityReducer.reduce(
                        action: EntityAction<StubEntity>.failure(entityError),
                        currentState: currentState
                    )
                }

                it("returns the .failure loadState") {
                    expect(resultState.loadState) == .failure(entityError)
                }

                it("returns the currentValue held previously") {
                    expect(resultState.currentValue) == stubEntity
                }
            }

        }

    }

}
