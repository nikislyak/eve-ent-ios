//
//  NetworkingGateway.swift
//  Library
//
//  Created by Nikita Kislyakov on 23.01.2020.
//

import Foundation
import Combine
import Overture

extension URLRequest {
    public func perform<R: Decodable>(on network: Network) -> AnyPublisher<R, Error> {
        network.perform(request: self)
    }
}

open class Network {
    private let env: Environment
    
    public init(env: Environment) {
        self.env = env
    }
    
    public func request(path: String) -> IncompleteRequest {
        .init(network: self, builder: .init(baseUrl: env.baseUrl, path: path))
    }
    
    open func perform<R: Decodable>(request: URLRequest) -> AnyPublisher<R, Error> {
        env.urlSession
            .dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: R.self, decoder: env.decoder)
            .eraseToAnyPublisher()
    }
}

public typealias DataTaskResult = (data: Data, response: URLResponse)

public protocol URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<DataTaskResult, Error>
}

extension Network {
    public struct Environment {
        public let urlSession: URLSessionProtocol
        public let baseUrl: URL
        public let decoder: JSONDecoder
        public let encoder: JSONEncoder
    }
}
