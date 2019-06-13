//
//  TestAppAction.swift
//  SwiftDux-iOS
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import SwiftDux

public struct NoOpAction: Action {
    public init() {}
}

public struct SetIntSubstateAction: Action {
    public let value: Int?

    public init(_ value: Int?) {
        self.value = value
    }
}

public struct SetStringSubstateAction: Action {
    public let value: String?

    public init(_ value: String?) {
        self.value = value
    }
}
