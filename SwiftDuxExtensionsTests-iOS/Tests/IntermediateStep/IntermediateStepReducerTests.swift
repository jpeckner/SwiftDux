//
//  IntermediateStepReducerTests.swift
//  SwiftDuxExtensionsTests-iOS
//
//  Created by Justin Peckner.
//  Copyright © 2020 Justin Peckner. All rights reserved.
//

import Nimble
import Quick
import SwiftDuxExtensions
import SwiftDuxTestComponents

class IntermediateStepReducerTests: QuickSpec {

    // swiftlint:disable implicitly_unwrapped_optional
    override func spec() {

        var result: IntermediateStepLoadState<StubError>!

        describe("reduce()") {

            context("when the current state is nil") {
                beforeEach {
                    result = IntermediateStepLoadReducer.reduce(action: .success,
                                                                currentState: nil)
                }

                it("returns .inProgress") {
                    expect(result) == .inProgress
                }
            }

            context("else when the action is .inProgress") {
                beforeEach {
                    result = IntermediateStepLoadReducer.reduce(action: .inProgress,
                                                                currentState: .success)
                }

                it("returns .inProgress") {
                    expect(result) == .inProgress
                }
            }

            context("else when the action is .success") {
                beforeEach {
                    result = IntermediateStepLoadReducer.reduce(action: .success,
                                                                currentState: .inProgress)
                }

                it("returns .success") {
                    expect(result) == .success
                }
            }

            context("else when the action is .failure") {
                beforeEach {
                    result = IntermediateStepLoadReducer.reduce(action: .failure(StubError.plainError),
                                                                currentState: .inProgress)
                }

                it("returns .failure, with the underlying error") {
                    expect(result) == .failure(StubError.plainError)
                }
            }

        }

    }

}
