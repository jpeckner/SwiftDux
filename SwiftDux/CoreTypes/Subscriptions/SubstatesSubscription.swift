//
//  SubstatesSubscription.swift
//  SwiftDux
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

import Foundation

public protocol SubstatesSubscriber: StoreSubscriber {
    func newState(state: StoreState,
                  updatedSubstates: Set<PartialKeyPath<StoreState>>)
}

public class SubstatesSubscription<Subscriber: SubstatesSubscriber> {

    public typealias StoreState = Subscriber.StoreState
    public typealias SubscribedPaths = [PartialKeyPath<StoreState>: StateEqualityBlock<StoreState>]

    private weak var subscriber: Subscriber?
    public let subscribedPaths: SubscribedPaths
    private let dispatchQueue: DispatchQueue
    public let objectIdentifier: ObjectIdentifier

    public init(subscriber: Subscriber,
                subscribedPaths: SubscribedPaths,
                dispatchQueue: DispatchQueue = .main) {
        self.subscriber = subscriber
        self.subscribedPaths = subscribedPaths
        self.dispatchQueue = dispatchQueue
        self.objectIdentifier = ObjectIdentifier(subscriber)
    }

}

extension SubstatesSubscription {

    public convenience init(subscriber: Subscriber,
                            equatableKeyPaths: Set<EquatableKeyPath<StoreState>>,
                            dispatchQueue: DispatchQueue = .main) {
        let subscribedPaths: SubscribedPaths = equatableKeyPaths.reduce([:]) { previousResult, dictEntry in
            var newResult = previousResult
            newResult[dictEntry.keyPath] = dictEntry.equalityBlock
            return newResult
        }

        self.init(subscriber: subscriber,
                  subscribedPaths: subscribedPaths,
                  dispatchQueue: dispatchQueue)
    }

    public convenience init<TKeyPath: Equatable>(subscriber: Subscriber,
                                                 keyPath: KeyPath<StoreState, TKeyPath>,
                                                 dispatchQueue: DispatchQueue = .main) {
        self.init(subscriber: subscriber,
                  equatableKeyPaths: [EquatableKeyPath<StoreState>(keyPath)],
                  dispatchQueue: dispatchQueue)
    }

}

extension SubstatesSubscription: StoreSubscriptionProtocol {

    public func processInitialState(newState: StoreState) {
        dispatchUpdate(newState,
                       updatedSubstates: Array(subscribedPaths.keys))
    }

    public func processUpdateState(oldState: StoreState, newState: StoreState) {
        let updatedSubstates = subscribedPaths.compactMap { keyPath, equalityBlock in
            return !equalityBlock(oldState, newState) ? keyPath : nil
        }
        guard !updatedSubstates.isEmpty else { return }

        dispatchUpdate(newState,
                       updatedSubstates: updatedSubstates)
    }

    public func getSubscriber() -> AnyObject? {
        return subscriber
    }

    private func dispatchUpdate(_ newState: StoreState,
                                updatedSubstates: [PartialKeyPath<StoreState>]) {
        dispatchQueue.async { [weak self] in
            self?.subscriber?.newState(state: newState,
                                       updatedSubstates: Set(updatedSubstates))
        }
    }

}
