//
//  OperationQueue+CurrentTests.swift
//  SwiftDuxTests
//
//  Copyright (c) 2019 Justin Peckner
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
