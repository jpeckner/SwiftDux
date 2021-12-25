//
//  GuaranteedEntityActionCreatorTests.swift
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

private enum TestGuaranteedEntityActionCreator: GuaranteedEntityActionCreator {}

class GuaranteedEntityActionCreatorTests: QuickSpec {

    // swiftlint:disable function_body_length
    // swiftlint:disable implicitly_unwrapped_optional
    override func spec() {

        describe("loadGuaranteedEntity") {

            let stubEntity = StubEntity.stubValue()

            var mockStore: MockStore<TestAppState>!

            beforeEach {
                mockStore = MockStore()
            }

            context("when the load block is non-throwing") {

                var mockService: MockEntityService!

                func performTest(returnedResult: Result<StubEntity, StubError>,
                                 actionWaitCount: Int = 2) {
                    mockService = MockEntityService(returnedResult: returnedResult)
                    let loadBlock = EntityLoadBlock.nonThrowing(mockService.fetchStubEntity)

                    waitFor(mockStore, toReachNonAsyncActionCount: actionWaitCount) {
                        let action: AsyncAction<TestAppState>
                            = TestGuaranteedEntityActionCreator.loadGuaranteedEntity(loadBlock)
                        mockStore.dispatch(action)
                    }
                }

                it("dispatches GuaranteedEntityAction.inProgress") {
                    performTest(returnedResult: .failure(StubError.plainError),
                                actionWaitCount: 1)

                    let dispatchedAction = mockStore.dispatchedNonAsyncActions.first
                    expect(dispatchedAction as? GuaranteedEntityAction<StubEntity>) == .inProgress
                }

                it("calls mockEntityService.fetchStubEntity") {
                    performTest(returnedResult: .failure(StubError.plainError),
                                actionWaitCount: 1)
                    expect(mockService.fetchStubEntityCalled) == true
                }

                context("when the load block returns success") {
                    beforeEach {
                        performTest(returnedResult: .success(stubEntity))
                    }

                    it("dispatches GuaranteedEntityAction.success") {
                        verifySuccess()
                    }
                }

                context("else when the load block returns failure") {
                    beforeEach {
                        performTest(returnedResult: .failure(StubError.plainError))
                    }

                    it("dispatches GuaranteedEntityAction.fallback") {
                        verifyLoadError()
                    }
                }
            }

            context("else when the load block is throwing") {

                var mockService: MockThrowingEntityService!

                func performTest(courseOfAction: MockThrowingEntityService.CourseOfAction,
                                 actionWaitCount: Int) {
                    mockService = MockThrowingEntityService(courseOfAction: courseOfAction)
                    let loadBlock = EntityLoadBlock.throwing(mockService.fetchStubEntity)

                    waitFor(mockStore, toReachNonAsyncActionCount: actionWaitCount) {
                        let action: AsyncAction<TestAppState>
                            = TestGuaranteedEntityActionCreator.loadGuaranteedEntity(loadBlock)
                        mockStore.dispatch(action)
                    }
                }

                it("dispatches GuaranteedEntityAction.inProgress") {
                    performTest(courseOfAction: .throwError(StubError.thrownError),
                                actionWaitCount: 1)

                    let dispatchedAction = mockStore.dispatchedNonAsyncActions.first
                    expect(dispatchedAction as? GuaranteedEntityAction<StubEntity>) == .inProgress
                }

                it("calls mockEntityService.fetchStubEntity") {
                    performTest(courseOfAction: .throwError(StubError.thrownError),
                                actionWaitCount: 1)

                    expect(mockService.fetchStubEntityCalled) == true
                }

                context("when the load block throws an error") {
                    beforeEach {
                        performTest(courseOfAction: .throwError(StubError.thrownError),
                                    actionWaitCount: 2)
                    }

                    it("dispatches GuaranteedEntityAction.failure(.preloadError)") {
                        verifyPreloadError()
                    }
                }

                context("else when the load block returns failure") {
                    beforeEach {
                        performTest(courseOfAction: .callbackWithResult(.failure(StubError.plainError)),
                                    actionWaitCount: 2)
                    }

                    it("dispatches GuaranteedEntityAction.fallback") {
                        verifyLoadError()
                    }
                }

                context("else when the load block returns success") {
                    beforeEach {
                        performTest(courseOfAction: .callbackWithResult(.success(stubEntity)),
                                    actionWaitCount: 2)
                    }

                    it("dispatches GuaranteedEntityAction.success") {
                        verifySuccess()
                    }
                }
            }

            func verifyPreloadError() {
                let dispatchedAction = mockStore.dispatchedNonAsyncActions.last as? GuaranteedEntityAction<StubEntity>
                let underlyingError = EquatableError(StubError.thrownError)
                expect(dispatchedAction) == .failure(.preloadError(underlyingError: underlyingError))
            }

            func verifyLoadError() {
                let dispatchedAction = mockStore.dispatchedNonAsyncActions.last as? GuaranteedEntityAction<StubEntity>
                let underlyingError = EquatableError(StubError.plainError)
                expect(dispatchedAction) == .failure(.loadError(underlyingError: underlyingError))
            }

            func verifySuccess() {
                let dispatchedAction = mockStore.dispatchedNonAsyncActions.last as? GuaranteedEntityAction<StubEntity>
                expect(dispatchedAction) == .success(stubEntity)
            }

        }

    }

}
