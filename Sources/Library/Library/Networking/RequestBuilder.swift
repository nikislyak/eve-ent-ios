//
//  RequestBuilder.swift
//  Data
//
//  Created by Nikita Kislyakov on 28.01.2020.
//

import Foundation

public struct RequestBuilder {
    private let request: URLRequest
    
    public init(baseUrl: URL, path: String) {
        self.request = .init(url: baseUrl.appendingPathComponent(path))
    }
    
    private init(request: URLRequest) {
        self.request = request
    }
    
    private func withCopy<T>(of smth: T, _ configure: (inout T) -> Void) -> T {
        var copy = smth
        
        configure(&copy)
        
        return copy
    }
    
    public func method(_ httpMethod: HTTPMethod) -> Self {
        .init(
            request: withCopy(of: request) {
                $0.httpMethod = httpMethod.rawValue
            }
        )
    }
    
    public func headers(_ dict: [String: String]) -> Self {
        .init(
            request: withCopy(of: request) { req in
                dict.forEach {
                    req.addValue($0.value, forHTTPHeaderField: $0.key)
                }
            }
        )
    }
    
    public func header(key: String, value: String) -> Self {
        .init(
            request: withCopy(of: request) {
                $0.addValue(value, forHTTPHeaderField: key)
            }
        )
    }
    
    public func set<V>(_ kp: WritableKeyPath<URLRequest, V>, _ value: V) -> Self {
        .init(
            request: withCopy(of: request) {
                $0[keyPath: kp] = value
            }
        )
    }
    
    public func param(key: String, value: String) -> Self {
        .init(
            request: withCopy(of: request) { copy in
                guard let url = copy.url?.absoluteString else { return }
                
                var components = URLComponents(string: url)
                
                let oldItems = components?.queryItems ?? []
                
                components?.queryItems = oldItems + [.init(name: key, value: value)]
                
                copy.url = components?.url
            }
        )
    }
    
    public func body(data: Data) -> Self {
        .init(
            request: withCopy(of: request) {
                $0.httpBody = data
            }
        )
    }
    
    public func build() -> URLRequest {
        request
    }
}
