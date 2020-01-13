//
//  Publishers+Operators.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 11.12.2019.
//

import Foundation
import Combine

extension Publishers {
    public struct FlatMapLatest<Upstream: Publisher, P: Publisher>: Publisher where P.Failure == Upstream.Failure {
        public typealias Failure = Upstream.Failure
        
        public typealias Output = P.Output

        public let upstream: Upstream

        public let transform: (Upstream.Output) -> P

        public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> P) {
            self.upstream = upstream
            self.transform = transform
        }

        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Upstream.Failure == S.Failure {
            upstream
                .map(transform)
                .switchToLatest()
                .receive(subscriber: subscriber)
        }
    }
    
    public struct TryFlatMapLatest<Upstream: Publisher, P: Publisher>: Publisher {
        public typealias Output = P.Output
        
        public typealias Failure = Error
        
        public let upstream: Upstream
        
        public let transform: (Upstream.Output) throws -> P
        
        init(upstream: Upstream, transform: @escaping (Upstream.Output) throws -> P) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            upstream
                .tryMap(transform)
                .map { $0.mapError { $0 as Error } }
                .switchToLatest()
                .receive(subscriber: subscriber)
        }
    }
}

extension Publisher {
    public func flatMapLatest<P: Publisher>(_ transform: @escaping (Output) -> P) -> Publishers.FlatMapLatest<Self, P> {
        .init(upstream: self, transform: transform)
    }
    
    public func tryFlatMapLatest<P: Publisher>(_ transform: @escaping (Output) throws -> P) -> Publishers.TryFlatMapLatest<Self, P> {
        .init(upstream: self, transform: transform)
    }
}

extension Empty {
    static var never: Empty<Output, Failure> {
        .init(completeImmediately: false)
    }
}
