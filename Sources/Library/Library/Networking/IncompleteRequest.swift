//
//  IncompleteRequest.swift
//  Library
//
//  Created by Nikita Kislyakov on 29.01.2020.
//

import Foundation
import Combine

public struct IncompleteRequest<R: Decodable> {
    let network: Network
    let builder: RequestBuilder
    
    public func method(_ httpMethod: HTTPMethod) -> Self {
        .init(network: network, builder: builder.method(httpMethod))
    }
    
    public func headers(_ dict: [String: String]) -> Self {
        .init(network: network, builder: builder.headers(dict))
    }
    
    public func header(key: String, value: String) -> Self {
        .init(network: network, builder: builder.header(key: key, value: value))
    }
    
    public func set<V>(_ kp: WritableKeyPath<URLRequest, V>, _ value: V) -> Self {
        .init(network: network, builder: builder.set(kp, value))
    }
    
    public func param(key: String, value: String) -> Self {
        .init(network: network, builder: builder.param(key: key, value: value))
    }
    
    public func body(data: Data) -> Self {
        .init(network: network, builder: builder.body(data: data))
    }
    
    public func perform() -> AnyPublisher<R, Error> {
        network.perform(request: builder.build())
    }
}
