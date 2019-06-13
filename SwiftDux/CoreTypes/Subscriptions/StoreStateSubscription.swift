//
//  StoreStateSubscription.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation

public protocol StoreStateSubscriber: StoreSubscriber {
    func newState(state: StoreState)
}

public class StoreStateSubscription<Subscriber: StoreStateSubscriber> {

    public typealias StoreState = Subscriber.StoreState

    private weak var subscriber: Subscriber?
    private let equalityBlock: StateEqualityBlock<StoreState>
    private let dispatchQueue: DispatchQueue
    public let objectIdentifier: ObjectIdentifier

    public init(subscriber: Subscriber,
                equalityBlock: @escaping StateEqualityBlock<StoreState>,
                dispatchQueue: DispatchQueue = .main) {
        self.subscriber = subscriber
        self.equalityBlock = equalityBlock
        self.dispatchQueue = dispatchQueue
        self.objectIdentifier = ObjectIdentifier(subscriber)
    }

}

extension StoreStateSubscription where Subscriber.StoreState: Equatable {

    public convenience init(subscriber: Subscriber,
                            dispatchQueue: DispatchQueue = .main) {
        self.init(subscriber: subscriber,
                  equalityBlock: ==,
                  dispatchQueue: dispatchQueue)
    }

}

extension StoreStateSubscription: StoreSubscriptionProtocol {

    public func processInitialState(newState: StoreState) {
        notifyNewState(newState)
    }

    public func processUpdateState(oldState: StoreState, newState: StoreState) {
        guard !equalityBlock(oldState, newState) else { return }
        notifyNewState(newState)
    }

    public func getSubscriber() -> AnyObject? {
        return subscriber
    }

    private func notifyNewState(_ newState: StoreState) {
        dispatchQueue.async { [weak self] in
            self?.subscriber?.newState(state: newState)
        }
    }

}
