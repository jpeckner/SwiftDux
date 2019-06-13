//
//  SubstatesSubscription.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

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

    public convenience init<E: Equatable>(subscriber: Subscriber,
                                          keyPath: KeyPath<StoreState, E>,
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
