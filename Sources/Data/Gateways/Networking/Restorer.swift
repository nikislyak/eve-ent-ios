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

public protocol RefreshTokensGateway {
    func newTokens(refreshToken: String) -> AnyPublisher<Tokens, Error>
}

public class RefreshTokensGatewayImpl: RefreshTokensGateway {
    private let network: Network
    
    public init(network: Network) {
        self.network = network
    }
    
    public func newTokens(refreshToken: String) -> AnyPublisher<Tokens, Error> {
        return network
            .request(path: "auth/refresh/", encoding: JSONEncoding())
            .method(.POST)
            .param(key: "refresh_token", value: refreshToken)
            .perform()
    }
}

public class Restorer: RequestRestorer {
    public enum Error: Swift.Error {
        case notAuthorized
    }
    
    private let tokensStorage: Storage
    private let refreshTokensGateway: RefreshTokensGateway
    
    public init(tokensStorage: Storage, refreshTokensGateway: RefreshTokensGateway) {
        self.tokensStorage = tokensStorage
        self.refreshTokensGateway = refreshTokensGateway
    }
    
    public func restore() -> AnyPublisher<Void, Swift.Error> {
        Just(())
            .tryMap { [refreshTokensGateway, tokensStorage] _ -> AnyPublisher<Tokens, Swift.Error> in
                guard let tokens = tokensStorage.getObject(forKey: "tokens") as Tokens? else {
                    return Fail(error: Error.notAuthorized).eraseToAnyPublisher()
                }
                
                return refreshTokensGateway.newTokens(refreshToken: tokens.refreshToken)
            }
            .flatMap { $0 }
            .map { [tokensStorage] in
                tokensStorage.save(object: $0, forKey: "tokens")
            }
            .eraseToAnyPublisher()
    }
}
