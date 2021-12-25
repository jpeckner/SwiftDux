//
//  EntityActionCreatorTests.swift
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

private enum TestEntityActionCreator: EntityActionCreator {}

class EntityActionCreatorTests: QuickSpec {

    // swiftlint:disable function_body_length
    // swiftlint:disable implicitly_unwrapped_optional
    override func spec() {

        describe("loadEntity") {

            let stubEntity = StubEntity.stubValue()
            let stubError = StubError.plainError

            var mockStore: MockStore<TestAppState>!

            beforeEach {
                mockStore = MockStore()
            }

            context("when the load block is non-throwing") {

                var mockService: MockEntityService!

                func performTest(returnedResult: Result<StubEntity, StubError>,
                                 actionWaitCount: Int = 2) {
                    mockService = MockEntityService(returnedResult: returnedResult)

                    waitFor(mockStore, toReachNonAsyncActionCount: actionWaitCount) {
                        let action: AsyncAction<TestAppState>
                            = TestEntityActionCreator.loadEntity(.nonThrowing(mockService.fetchStubEntity))
                        mockStore.dispatch(action)
                    }
                }

                it("dispatches EntityAction.inProgress") {
                    performTest(returnedResult: .failure(stubError),
                                actionWaitCount: 1)
                    expect(mockStore.dispatchedNonAsyncActions.first as? EntityAction<StubEntity>) == .inProgress
                }

                it("calls mockEntityService.fetchStubEntity") {
                    performTest(returnedResult: .failure(stubError),
                                actionWaitCount: 1)
                    expect(mockService.fetchStubEntityCalled) == true
                }

                context("else when the load block returns failure") {
                    beforeEach {
                        performTest(returnedResult: .failure(stubError))
                    }

                    it("dispatches EntityAction.failure(.loadError)") {
                        verifyLoadError()
                    }
                }

                context("when the load block returns success") {
                    beforeEach {
                        performTest(returnedResult: .success(stubEntity))
                    }

                    it("dispatches EntityAction.success") {
                        verifySuccess()
                    }
                }
            }

            context("else when the load block is throwing") {

                var mockService: MockThrowingEntityService!

                func performTest(courseOfAction: MockThrowingEntityService.CourseOfAction,
                                 actionWaitCount: Int = 2) {
                    mockService = MockThrowingEntityService(courseOfAction: courseOfAction)

                    waitFor(mockStore, toReachNonAsyncActionCount: actionWaitCount) {
                        let action: AsyncAction<TestAppState>
                            = TestEntityActionCreator.loadEntity(.throwing(mockService.fetchStubEntity))
                        mockStore.dispatch(action)
                    }
                }

                it("dispatches EntityAction.inProgress") {
                    performTest(courseOfAction: .throwError(StubError.thrownError),
                                actionWaitCount: 1)
                    expect(mockStore.dispatchedNonAsyncActions.first as? EntityAction<StubEntity>) == .inProgress
                }

                it("calls mockEntityService.fetchStubEntity") {
                    performTest(courseOfAction: .throwError(StubError.thrownError),
                                actionWaitCount: 1)
                    expect(mockService.fetchStubEntityCalled) == true
                }

                context("when the load block throws an error") {
                    beforeEach {
                        performTest(courseOfAction: .throwError(StubError.thrownError))
                    }

                    it("dispatches EntityAction.failure(.preloadError)") {
                        verifyPreloadError()
                    }
                }

                context("else when the load block returns failure") {
                    beforeEach {
                        performTest(courseOfAction: .callbackWithResult(.failure(stubError)))
                    }

                    it("dispatches EntityAction.failure(.loadError)") {
                        verifyLoadError()
                    }
                }

                context("else when the load block returns success") {
                    beforeEach {
                        performTest(courseOfAction: .callbackWithResult(.success(stubEntity)))
                    }

                    it("dispatches EntityAction.success") {
                        verifySuccess()
                    }
                }
            }

            func verifyPreloadError() {
                let dispatchedAction = mockStore.dispatchedNonAsyncActions.last as? EntityAction<StubEntity>
                guard case let .failure(entityError)? = dispatchedAction,
                    case let .preloadError(underlyingError) = entityError,
                    case .thrownError? = underlyingError.value as? StubError
                else {
                    fail("Unexpected Action found: \(String(describing: dispatchedAction))")
                    return
                }
            }

            func verifyLoadError() {
                let dispatchedAction = mockStore.dispatchedNonAsyncActions.last as? EntityAction<StubEntity>
                guard case let .failure(entityError)? = dispatchedAction,
                    case let .loadError(underlyingError) = entityError,
                    case .plainError? = underlyingError.value as? StubError
                else {
                    fail("Unexpected Action found: \(String(describing: dispatchedAction))")
                    return
                }
            }

            func verifySuccess() {
                let dispatchedAction = mockStore.dispatchedNonAsyncActions.last as? EntityAction<StubEntity>
                guard case let .success(entity)? = dispatchedAction else {
                    fail("Unexpected Action found: \(String(describing: dispatchedAction))")
                    return
                }

                expect(entity) == stubEntity
            }

        }

    }

}
