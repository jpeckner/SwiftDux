//
//  XCTestCase+Expectations.swift
//  SwiftDuxTestComponents
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation
import SwiftDux
import XCTest

public let defaultWaitTime: TimeInterval = 0.1

extension XCTestCase {

    public func waitForExpectations(_ expectations: [XCTestExpectation],
                                    withTimeout timeout: TimeInterval = defaultWaitTime) {
        wait(for: expectations, timeout: timeout)
    }

    public func waitForDispatch(_ dispatchQueue: DispatchQueue,
                                timeout: TimeInterval = defaultWaitTime,
                                function: String = #function,
                                line: Int = #line) {
        let dispatchExpectation = expectation(description: "waitForDispatch-\(function)-\(line)")
        dispatchQueue.async { dispatchExpectation.fulfill() }

        waitForExpectations([dispatchExpectation],
                            withTimeout: timeout)
    }

}
