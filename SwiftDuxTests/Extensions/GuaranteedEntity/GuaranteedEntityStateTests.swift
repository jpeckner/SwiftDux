//
//  GuaranteedEntityStateTests.swift
//  SwiftDuxExtensionsTests
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

import Nimble
import Quick
import SwiftDux
import SwiftDuxTestComponents

class GuaranteedEntityStateTests: QuickSpec {

    // swiftlint:disable function_body_length
    // swiftlint:disable implicitly_unwrapped_optional
    override func spec() {

        let stubValue: StubEntity = .stubValue()

        var result: StubGuaranteedEntityState<EntityError<StubError>>!

        describe("init()") {

            beforeEach {
                result = StubGuaranteedEntityState()
            }

            it("returns loadState with a value of .idle") {
                expect(result.loadState) == .idle
            }

        }

        describe("currentValue") {

            context("when the loadState is .success") {
                beforeEach {
                    result = StubGuaranteedEntityState(loadState: .success(stubValue))
                }

                it("returns the value embedded in loadState") {
                    expect(result.currentValue) == stubValue
                    expect(result.currentValue) != StubGuaranteedEntityState<EntityError<StubError>>.fallbackValue
                }
            }

            let fallbackLoadStates: [GuaranteedEntityLoadState<StubEntity, EntityError>] = [
                .idle,
                .inProgress,
                .failure(.loadError(underlyingError: StubError.plainError))
            ]

            for loadState in fallbackLoadStates {

                context("when the loadState is \(loadState)") {
                    beforeEach {
                        result = StubGuaranteedEntityState(loadState: loadState)
                    }

                    it("returns the fallback state value") {
                        expect(result.currentValue) == StubGuaranteedEntityState<EntityError<StubError>>.fallbackValue
                    }
                }

            }

        }

        describe("hasCompletedLoading") {

            let nonFinishedStates: [GuaranteedEntityLoadState<StubEntity, EntityError<StubError>>] = [
                .idle,
                .inProgress,
            ]

            for loadState in nonFinishedStates {

                context("when the loadState is \(loadState)") {
                    beforeEach {
                        result = StubGuaranteedEntityState(loadState: loadState)
                    }

                    it("returns false") {
                        expect(result.hasCompletedLoading) == false
                    }
                }

            }

            let finishedStates: [GuaranteedEntityLoadState<StubEntity, EntityError<StubError>>] = [
                .success(stubValue),
                .failure(.loadError(underlyingError: StubError.plainError))
            ]

            for loadState in finishedStates {

                context("when the loadState is \(loadState)") {
                    beforeEach {
                        result = StubGuaranteedEntityState(loadState: loadState)
                    }

                    it("returns true") {
                        expect(result.hasCompletedLoading) == true
                    }
                }

            }

        }

    }

}
