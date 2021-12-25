//
//  GuaranteedEntityReducerTests.swift
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
import SwiftDux
import SwiftDuxTestComponents

class GuaranteedEntityReducerTests: QuickSpec {

    // swiftlint:disable function_body_length
    // swiftlint:disable implicitly_unwrapped_optional
    override func spec() {

        describe("reduce") {

            var resultState: StubGuaranteedEntityState!

            context("when the action is not a GuaranteedEntityAction") {
                let currentState = StubGuaranteedEntityState(loadState: .inProgress)

                beforeEach {
                    resultState = StubGuaranteedEntityReducer.reduce(action: StubAction.genericAction,
                                                                     currentState: currentState)
                }

                it("returns the current state") {
                    expect(resultState) == currentState
                }
            }

            context("when the action is .inProgress") {
                let currentState = StubGuaranteedEntityState(loadState: .idle)

                beforeEach {
                    resultState = StubGuaranteedEntityReducer.reduce(
                        action: GuaranteedEntityAction<StubEntity>.inProgress,
                        currentState: currentState
                    )
                }

                it("returns the .inProgress loadState") {
                    expect(resultState.loadState) == .inProgress
                }

                it("returns the fallbackValue for currentValue") {
                    expect(resultState.currentValue) == StubGuaranteedEntityState.fallbackValue
                }
            }

            context("when the action is .success") {
                let currentState = StubGuaranteedEntityState(loadState: .inProgress)
                let newValue = StubEntity(stringValue: "XYZ",
                                          intValue: 200,
                                          doubleValue: 7.5)

                beforeEach {
                    resultState = StubGuaranteedEntityReducer.reduce(
                        action: GuaranteedEntityAction<StubEntity>.success(newValue),
                        currentState: currentState
                    )
                }

                it("returns the .success loadState") {
                    expect(resultState.loadState) == .success(newValue)
                }

                it("returns the new entity as currentValue") {
                    expect(resultState.currentValue) == newValue
                }
            }

            context("when the action is .failure") {
                let currentState = StubGuaranteedEntityState(loadState: .inProgress)
                let entityError = EntityError.loadError(underlyingError: EquatableError(StubError.plainError))

                beforeEach {
                    let action = GuaranteedEntityAction<StubEntity>.failure(entityError)
                    resultState = StubGuaranteedEntityReducer.reduce(action: action,
                                                                     currentState: currentState)
                }

                it("returns the .failure loadState") {
                    expect(resultState.loadState) == .failure(entityError)
                }

                it("returns the fallback value for currentValue") {
                    expect(resultState.currentValue) == StubGuaranteedEntityState.fallbackValue
                }
            }

        }

    }

}
