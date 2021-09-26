//
//  MockThrowingEntityService.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation

public class MockThrowingEntityService {

    public enum CourseOfAction {
        case throwError(Error)
        case callbackWithResult(Result<StubEntity, StubError>)
    }

    private let courseOfAction: CourseOfAction
    private let responseQueue: DispatchQueue

    public private(set) var fetchStubEntityCalled = false

    public init(courseOfAction: CourseOfAction,
                responseQueue: DispatchQueue = .global()) {
        self.courseOfAction = courseOfAction
        self.responseQueue = responseQueue
    }

    public func fetchStubEntity(completion: @escaping (Result<StubEntity, StubError>) -> Void) throws {
        fetchStubEntityCalled = true

        switch courseOfAction {
        case let .throwError(error):
            throw error
        case let .callbackWithResult(result):
            responseQueue.async {
                completion(result)
            }
        }
    }

}
