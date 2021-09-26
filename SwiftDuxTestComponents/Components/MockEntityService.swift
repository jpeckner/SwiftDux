//
//  MockEntityService.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation
import SwiftDuxExtensions

public class MockEntityService {

    private let returnedResult: Result<StubEntity, StubError>
    private let responseQueue: DispatchQueue

    public private(set) var fetchStubEntityCalled = false

    public init(returnedResult: Result<StubEntity, StubError>,
                responseQueue: DispatchQueue = .global()) {
        self.returnedResult = returnedResult
        self.responseQueue = responseQueue
    }

    public func fetchStubEntity(completion: @escaping (Result<StubEntity, StubError>) -> Void) {
        fetchStubEntityCalled = true

        responseQueue.async {
            completion(self.returnedResult)
        }
    }

}
