//
//  Reducer.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

public typealias Reducer<State> = (_ action: Action, _ state: State) -> State
