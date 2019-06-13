//
//  Store.swift
//  SwiftDux
//
//  Created by Justin Peckner.
//  Copyright © 2019 Justin Peckner. All rights reserved.
//

import Foundation

public class Store<State: StateProtocol>: StoreProtocol {

    private let reducer: Reducer<State>
    private let middleware: [Middleware<State>]
    private let qualityOfService: QualityOfService
    private var storeFields: StoreFields<State>

    /// Initializes the store. Middleware is applied in the order found in the array.
    ///
    /// - parameter reducer: Main reducer that processes incoming actions.
    /// - parameter initialState: The initial state of the Store.
    /// - parameter middleware: Ordered list of action pre-processors, acting before the root reducer.
    /// - parameter qualityOfService: QualityOfService for the OperationQueue on which state changes/subscriber updates
    ///             are sequentially processed.
    public init(reducer: @escaping Reducer<State>,
                initialState: State,
                middleware: [Middleware<State>] = [],
                qualityOfService: QualityOfService = .userInitiated) {
        self.reducer = reducer
        let completeMiddleware = middleware + [asyncActionMiddleware()]
        self.middleware = completeMiddleware
        self.qualityOfService = qualityOfService

        self.storeFields = StoreFields(reducer: reducer,
                                       initialState: initialState,
                                       middleware: completeMiddleware,
                                       qualityOfService: qualityOfService)
    }

    public func subscribe<Subscription: StoreSubscriptionProtocol>(
        _ subscription: Subscription
    ) where Subscription.StoreState == State {
        storeFields.subscribe(subscription)
    }

    public func unsubscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreState == State {
        storeFields.unsubscribe(subscriber)
    }

    public func dispatch(_ action: Action) {
        storeFields.dispatchFunction(action)
    }

    public func reset(to state: State) {
        storeFields.cancelOperations()

        storeFields = StoreFields(reducer: reducer,
                                  initialState: state,
                                  middleware: middleware,
                                  qualityOfService: qualityOfService)
    }

}

private class StoreFields<State: StateProtocol> {

    private let reducer: Reducer<State>
    private let middleware: [Middleware<State>]
    private let operationQueue: OperationQueue

    private var subscriptions: Set<SubscriptionBox<State>> = []

    init(reducer: @escaping Reducer<State>,
         initialState: State,
         middleware: [Middleware<State>],
         qualityOfService: QualityOfService) {
        self.reducer = reducer
        self.state = initialState
        self.middleware = middleware

        self.operationQueue = OperationQueue()
        operationQueue.qualityOfService = qualityOfService
        operationQueue.maxConcurrentOperationCount = 1
    }

    private var state: State {
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

    lazy var dispatchFunction: DispatchFunction = {
        return
            middleware
            .reversed()
            .reduce({ [weak self] action in
                self?.operationQueue.executeLocally { [weak self] in self?.reduce(action) }
            }, { dispatchFunction, middleware in
                let dispatch: (Action) -> Void = { [weak self] in self?.dispatchFunction($0) }
                let stateBlock: (@escaping StateReceiverBlock<State>) -> Void = { [weak self] stateReceiverBlock in
                    self?.operationQueue.executeLocally { [weak self] in self?.passState(to: stateReceiverBlock) }
                }

                return middleware(dispatch, stateBlock)(dispatchFunction)
            })
    }()

    private func reduce(_ action: Action) {
        state = reducer(action, state)
    }

    private func passState(to stateReceiverBlock: StateReceiverBlock<State>) {
        stateReceiverBlock(state)
    }

    // MARK: Subscribe

    func subscribe<Subscription: StoreSubscriptionProtocol>(
        _ subscription: Subscription
    ) where Subscription.StoreState == State {
        operationQueue.executeLocally { [weak self] in self?.performSubscribe(subscription) }
    }

    private func performSubscribe<Subscription: StoreSubscriptionProtocol>(
        _ subscription: Subscription
    ) where Subscription.StoreState == State {
        let box = SubscriptionBox(objectIdentifier: subscription.objectIdentifier,
                                  getSubscriberBlock: subscription.getSubscriber,
                                  processInitialStateBlock: subscription.processInitialState,
                                  processUpdateStateBlock: subscription.processUpdateState)
        subscriptions.update(with: box)
        box.processInitialStateBlock(state)
    }

    // MARK: Unsubscribe

    func unsubscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreState == State {
        operationQueue.executeLocally { [weak self] in self?.performUnsubscribe(subscriber) }
    }

    private func performUnsubscribe<S: StoreSubscriber>(_ subscriber: S) where S.StoreState == State {
        guard let index = subscriptions.firstIndex(where: {
            return $0.getSubscriberBlock() === subscriber
        }) else { return }
        subscriptions.remove(at: index)
    }

    // MARK: Cancel operations

    func cancelOperations() {
        operationQueue.cancelAllOperations()
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
