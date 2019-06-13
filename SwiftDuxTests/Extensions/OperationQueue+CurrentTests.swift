//
//  OperationQueue+CurrentTests.swift
//  SwiftDuxTests
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import XCTest

private class MockOperationQueue: OperationQueue {

    private(set) var numAddOperationCalls = 0

    override func addOperation(_ operation: Operation) {
        numAddOperationCalls += 1
        super.addOperation(operation)
    }

}

class OperationQueueCurrentTests: XCTestCase {

    func testExecuteLocallyCalledFromSameQueue() {
        let blockExecutedExpectation = expectation(description: "blockExecutedExpectation")
        let operationQueue = MockOperationQueue()

        operationQueue.addOperation {
            XCTAssertEqual(operationQueue.numAddOperationCalls, 1)

            // When executeLocally() is called from the same queue...
            operationQueue.executeLocally {
                // ...it executes the block WITHOUT invoking addOperation()
                XCTAssertEqual(operationQueue.numAddOperationCalls, 1)
                blockExecutedExpectation.fulfill()
            }
        }

        waitForExpectations([blockExecutedExpectation])
    }

    func testExecuteLocallyCalledFromOtherQueue() {
        let blockExecutedExpectation = expectation(description: "blockExecutedExpectation")
        let operationQueue = MockOperationQueue()
        let otherQueue = OperationQueue()

        otherQueue.addOperation {
            // When executeLocally() is called from another queue...
            operationQueue.executeLocally {
                // ...it executes the block by invoking addOperation()
                XCTAssertEqual(operationQueue.numAddOperationCalls, 1)
                blockExecutedExpectation.fulfill()
            }
        }

        waitForExpectations([blockExecutedExpectation])
    }

}
