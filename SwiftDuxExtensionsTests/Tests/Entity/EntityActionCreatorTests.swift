//
//  EntityActionCreatorTests.swift
//  SwiftDuxExtensionsTests
//
//  Created by Justin Peckner.
//  Copyright © 2018 Justin Peckner. All rights reserved.
//

import Nimble
import Quick
import SwiftDux
import SwiftDuxExtensions
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
