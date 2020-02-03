//
//  TokensStorageGateway.swift
//  Data
//
//  Created by Nikita Kislyakov on 30.01.2020.
//

import Foundation
import Domain
import Library
import Combine

public class TokensStorageGatewayImpl: TokensStorageGateway {
    private let tokensStorage: Storage
    
    public init(tokensStorage: Storage) {
        self.tokensStorage = tokensStorage
    }
    
    public func get() -> AnyPublisher<Tokens?, Error> {
        Result
            .Publisher(tokensStorage.getObject(forKey: "tokens") as Tokens?)
            .eraseToAnyPublisher()
    }
    
    public func save(_ tokens: Tokens) -> AnyPublisher<Void, Error> {
        Result
            .Publisher(tokensStorage.save(object: tokens, forKey: "tokens"))
            .eraseToAnyPublisher()
    }
    
    public func remove() -> AnyPublisher<Void, Error> {
        Result
            .Publisher(tokensStorage.removeObject(byKey: "tokens"))
            .eraseToAnyPublisher()
    }
}
