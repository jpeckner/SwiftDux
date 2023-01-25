//
//  Store.swift
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

open class Store<TAction: Action, TState: StateProtocol>: StoreProtocol {

    private let reducer: Reducer<TAction, TState>
    private let middleware: [Middleware<TAction, TState>]
    private let qualityOfService: QualityOfService
    private var storeFields: StoreFields<TAction, TState>

    /// Initializes the store. Middleware is applied in the order found in the array.
    ///
    /// - parameter reducer: Main reducer that processes incoming actions.
    /// - parameter initialState: The initial state of the Store.
    /// - parameter middleware: Ordered list of action pre-processors, acting before the root reducer.
    /// - parameter qualityOfService: QualityOfService for the OperationQueue on which state changes/subscriber updates
    ///             are sequentially processed.
    public init(reducer: @escaping Reducer<TAction, TState>,
                initialState: TState,
                middleware: [Middleware<TAction, TState>] = [],
                qualityOfService: QualityOfService = .userInitiated) {
        self.reducer = reducer
        self.middleware = middleware
        self.qualityOfService = qualityOfService

        self.storeFields = StoreFields(reducer: reducer,
                                       initialState: initialState,
                                       middleware: middleware,
                                       qualityOfService: qualityOfService)
    }

    open func subscribe<TSubscription: StoreSubscriptionProtocol>(
        _ subscription: TSubscription
    ) where TSubscription.StoreState == TState {
        storeFields.subscribe(subscription)
    }

    open func unsubscribe<TSubscriber: StoreSubscriber>(_ subscriber: TSubscriber) where TSubscriber.StoreState == TState {
        storeFields.unsubscribe(subscriber)
    }

    open func dispatch(_ action: TAction) {
        storeFields.dispatchFunction(action)
    }

}

private class StoreFields<TAction: Action, TState: StateProtocol> {

    private let reducer: Reducer<TAction, TState>
    private let middleware: [Middleware<TAction, TState>]
    private let operationQueue: OperationQueue

    private var subscriptions: Set<SubscriptionBox<TState>> = []

    init(reducer: @escaping Reducer<TAction, TState>,
         initialState: TState,
         middleware: [Middleware<TAction, TState>],
         qualityOfService: QualityOfService) {
        self.reducer = reducer
        self.state = initialState
        self.middleware = middleware

        self.operationQueue = OperationQueue()
        operationQueue.qualityOfService = qualityOfService
        operationQueue.maxConcurrentOperationCount = 1
    }

    private var state: TState {
        didSet {
            subscriptions.forEach {
                if $0.getSubscriberBlock() == nil {
                    subscriptions.remove($0)
                } else {
                    $0.processUpdateStateBlock(oldValue, state)
                }
            }
        }
    }

    // MARK: dispatchFunction

    lazy var dispatchFunction: DispatchFunction<TAction> = {
        return
            middleware
            .reversed()
            .reduce({ [weak self] action in
                self?.operationQueue.executeLocally { [weak self] in self?.reduce(action) }
            }, { dispatchFunction, middleware in
                let dispatch: (TAction) -> Void = { [weak self] in self?.dispatchFunction($0) }
                let stateBlock: (@escaping StateReceiverBlock<TState>) -> Void = { [weak self] stateReceiverBlock in
                    self?.operationQueue.executeLocally { [weak self] in self?.passState(to: stateReceiverBlock) }
                }

                return middleware(dispatch, stateBlock)(dispatchFunction)
            })
    }()

    private func reduce(_ action: TAction) {
        state = reducer(action, state)
    }

    private func passState(to stateReceiverBlock: StateReceiverBlock<TState>) {
        stateReceiverBlock(state)
    }

    // MARK: Subscribe

    func subscribe<Subscription: StoreSubscriptionProtocol>(
        _ subscription: Subscription
    ) where Subscription.StoreState == TState {
        operationQueue.executeLocally { [weak self] in self?.performSubscribe(subscription) }
    }

    private func performSubscribe<Subscription: StoreSubscriptionProtocol>(
        _ subscription: Subscription
    ) where Subscription.StoreState == TState {
        let box = SubscriptionBox(objectIdentifier: subscription.objectIdentifier,
                                  getSubscriberBlock: subscription.getSubscriber,
                                  processInitialStateBlock: subscription.processInitialState,
                                  processUpdateStateBlock: subscription.processUpdateState)
        subscriptions.update(with: box)
        box.processInitialStateBlock(state)
    }

    // MARK: Unsubscribe

    func unsubscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreState == TState {
        operationQueue.executeLocally { [weak self] in self?.performUnsubscribe(subscriber) }
    }

    private func performUnsubscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreState == TState {
        guard let index = subscriptions.firstIndex(where: {
            return $0.getSubscriberBlock() === subscriber
        }) else { return }
        subscriptions.remove(at: index)
    }

}

/// SubscriptionBox type-erases the specific type of a StoreSubscriptionProtocol instance, while maintaining a strong
/// reference to that subscription object (via maintaining strong references to its various blocks).
private class SubscriptionBox<StoreState: StateProtocol> {

    typealias GetSubscriberBlock = () -> AnyObject?
    typealias InitialStoreStateBlock<State: StateProtocol> = (State) -> Void
    typealias StoreStateUpdateBlock<State: StateProtocol> = (State, State) -> Void

    private let objectIdentifier: ObjectIdentifier
    let getSubscriberBlock: GetSubscriberBlock
    let processInitialStateBlock: InitialStoreStateBlock<StoreState>
    let processUpdateStateBlock: StoreStateUpdateBlock<StoreState>

    init(objectIdentifier: ObjectIdentifier,
         getSubscriberBlock: @escaping GetSubscriberBlock,
         processInitialStateBlock: @escaping InitialStoreStateBlock<StoreState>,
         processUpdateStateBlock: @escaping StoreStateUpdateBlock<StoreState>) {
        self.objectIdentifier = objectIdentifier
        self.getSubscriberBlock = getSubscriberBlock
        self.processInitialStateBlock = processInitialStateBlock
        self.processUpdateStateBlock = processUpdateStateBlock
    }

}

extension SubscriptionBox: Hashable {

    static func == (left: SubscriptionBox, right: SubscriptionBox) -> Bool {
        return left.objectIdentifier == right.objectIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(objectIdentifier)
    }

}
