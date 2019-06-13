//
//  OperationQueue+Current.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation

extension OperationQueue {

    public func executeLocally(block: @escaping () -> Void) {
        if OperationQueue.current === self {
            block()
        } else {
            addOperation(BlockOperation(block: block))
        }
    }

}
