//
//  Network.swift
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
    
    public func request<R: Decodable>(path: String) -> IncompleteRequest<R> {
        .init(network: self, builder: modify(request: .init(baseUrl: env.baseUrl, path: path)))
    }
    
    open func modify(request: RequestBuilder) -> RequestBuilder {
        request
    }
    
    open func perform<R: Decodable>(request: URLRequest) -> AnyPublisher<R, Error> {
        env.urlSession
            .dataTaskPublisher(for: request)
            .mapError(NetworkError.other)
            .flatMap { [env] dataTaskResult -> AnyPublisher<DataTaskResult, NetworkError> in
                guard env.responseValidator?.isValid(response: dataTaskResult.response) ?? true else {
                    return Fail(error: .validation).eraseToAnyPublisher()
                }
                
                return Result.Publisher(dataTaskResult).eraseToAnyPublisher()
            }
            .catch { [env] error in
                error.validation
                    ? env.urlSession.dataTaskPublisher(for: request)
                    : Fail(error: error).eraseToAnyPublisher()
            }
            .map(\.data)
            .decode(type: R.self, decoder: env.decoder)
            .eraseToAnyPublisher()
    }
}

public enum NetworkError: Error {
    case validation
    case other(Error)
    
    var validation: Bool {
        guard case .validation = self else {
            return false
        }
        
        return true
    }
    
    var other: Error? {
        guard case let .other(error) = self else {
            return nil
        }
        
        return error
    }
}

public protocol NetworkResponseValidator {
    func isValid(response: URLResponse) -> Bool
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
        public let responseValidator: NetworkResponseValidator?
    }
}
