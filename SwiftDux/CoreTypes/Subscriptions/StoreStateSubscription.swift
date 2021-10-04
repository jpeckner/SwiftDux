//
//  StoreStateSubscription.swift
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
