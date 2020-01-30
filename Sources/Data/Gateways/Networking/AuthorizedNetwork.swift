//
//  AuthorizedNetwork.swift
//  Data
//
//  Created by Nikita Kislyakov on 30.01.2020.
//

import Foundation
import Networking
import Combine
import Library

public class ResponseValidator: NetworkResponseValidator {
    public func isValid(response: URLResponse) -> Bool {
        (response as? HTTPURLResponse).map {
            !(400 ..< 500 ~= $0.statusCode)
        } ?? true
    }
}

public class Restorer: RequestRestorer {
    private let tokensStorage: Storage
    private let network: Network
    
    public init(tokensStorage: Storage, network: Network) {
        self.tokensStorage = tokensStorage
        self.network = network
    }
    
    public func restore() -> AnyPublisher<Void, Error> {
        Just(())
            .tryMap { [network] _ -> AnyPublisher<String, Error> in
                network
                    .request(path: "auth/refresh")
                    .method(.POST)
                    .body(data: try JSONEncoder().encode(""))
                    .perform()
        }
        .flatMap { $0 }
        .map { [tokensStorage] in
            tokensStorage.save(object: $0, forKey: "tokens")
        }
        .eraseToAnyPublisher()
    }
}

public class AuthorizedNetwork: Network {
    private let tokensStorage: Storage
    
    public init(tokensStorage: Storage, env: Environment) {
        self.tokensStorage = tokensStorage
        
        super.init(env: env)
    }
    
    override public func modify(request: RequestBuilder) -> RequestBuilder {
        tokensStorage
            .getObject(forKey: "tokens")
            .map {
                request.header(key: "Authorization", value: "Bearer " + $0)
            } ?? request
    }
}
