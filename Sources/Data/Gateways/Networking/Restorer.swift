//
//  Restorer.swift
//  Data
//
//  Created by Nikita Kislyakov on 30.01.2020.
//

import Foundation
import Networking
import Combine
import Library
import Domain

public class Restorer: RequestRestorer {
    public enum Error: Swift.Error {
        case notAuthorized
    }
    
    private let tokensStorage: Storage
    private let network: Network
    
    public init(tokensStorage: Storage, network: Network) {
        self.tokensStorage = tokensStorage
        self.network = network
    }
    
    public func restore() -> AnyPublisher<Void, Swift.Error> {
        Just(())
            .tryMap { [network, tokensStorage] _ -> AnyPublisher<Tokens, Swift.Error> in
                guard let tokens = tokensStorage.getObject(forKey: "tokens") as Tokens? else {
                    return Fail(error: Error.notAuthorized).eraseToAnyPublisher()
                }
                
                return network
                    .request(path: "auth/refresh/", encoding: JSONEncoding())
                    .method(.POST)
                    .param(key: "refresh_token", value: tokens.refreshToken)
                    .perform()
            }
            .flatMap { $0 }
            .map { [tokensStorage] in
                tokensStorage.save(object: $0, forKey: "tokens")
            }
            .eraseToAnyPublisher()
    }
}
