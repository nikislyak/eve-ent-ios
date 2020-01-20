//
//  StateMachine.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 09.12.2019.
//

import Foundation
import Combine

public final class PassthroughRelay<Output>: Publisher {
    private let subject = PassthroughSubject<Output, Never>()
    
    public typealias Failure = Never
    
    public func receive<S: Subscriber>(subscriber: S) where PassthroughRelay.Failure == S.Failure, PassthroughRelay.Output == S.Input {
        subject.receive(subscriber: subscriber)
    }
    
    public func accept(_ value: Output) {
        subject.send(value)
    }
}

public final class CurrentValueRelay<Output>: Publisher {
    private let subject: CurrentValueSubject<Output, Never>
    
    public typealias Failure = Never
    
    public init(_ value: Output) {
        subject = .init(value)
    }
    
    public func receive<S: Subscriber>(subscriber: S) where CurrentValueRelay.Failure == S.Failure, CurrentValueRelay.Output == S.Input {
        subject.receive(subscriber: subscriber)
    }
    
    public var value: Output {
        subject.value
    }
    
    public func accept(_ value: Output) {
        subject.send(value)
    }
}

public protocol EmptyInitializable {
    init()
}

public protocol Actionable {
    associatedtype Action
    
    mutating func reduce()
    mutating func execute(_ action: Action)
}

public protocol StateType: EmptyInitializable, Actionable {}

open class Store<State: StateType> {
    private var bag = Set<AnyCancellable>()
    private let stateRelay: CurrentValueRelay<State>
    private let actionRelay: PassthroughRelay<State.Action> = .init()

    public convenience init<Scheduler: Combine.Scheduler>(
        state initial: State = .init(),
        scheduler: Scheduler,
        build: (AnyPublisher<State, Never>) -> [AnyPublisher<State.Action, Never>]
    ) {
        self.init(
            state: initial,
            scheduler: scheduler,
            map: { state in
                Publishers.MergeMany(build(state)).eraseToAnyPublisher()
            }
        )
    }
    
    private init<Scheduler: Combine.Scheduler>(
        state initial: State = .init(),
        scheduler: Scheduler,
        map: (AnyPublisher<State, Never>) -> AnyPublisher<State.Action, Never>
    ) {
        stateRelay = .init(initial)

        actionRelay
            .receive(on: scheduler)
            .scan(initial) { state, action in
                var copy = state
                
                copy.reduce()
                copy.execute(action)
                
                return copy
            }
            .sink(receiveValue: { [weak self] in
                self?.stateRelay.accept($0)
            })
            .store(in: &bag)

        map(stateRelay.eraseToAnyPublisher())
            .sink(receiveValue: { [weak self] in
                self?.actionRelay.accept($0)
            })
            .store(in: &bag)
    }

    public var state: AnyPublisher<State, Never> {
        stateRelay.eraseToAnyPublisher()
    }

    /// Dispatch action to state
    open func dispatch(_ action: State.Action) {
        actionRelay.accept(action)
    }

    /// Create closure dispatching action to state
    /// Warning: capture reference to store
    open func dispatcher() -> (State.Action) -> Void {
        { action in self.dispatch(action) }
    }

    /// Create closure dispatching action to state
    /// Warning: closure capture store reference
    open func dispatcher(_ action: State.Action) -> () -> Void {
        { self.dispatch(action) }
    }

    /// Create closure dispatching action to state
    /// Warning: closure capture store reference
    open func dispatcher<V>(_ action: @escaping ((V) -> State.Action)) -> (V) -> Void {
        { value in self.dispatch(action(value)) }
    }
}
