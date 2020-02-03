//
//  AuthorizationUseCase.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Combine
import Library

public class AuthorizationUseCase {
    private let authGateway: AuthorizationGateway
    private let tokensStorageGateway: TokensStorageGateway
    
    public init(
        _ authGateway: AuthorizationGateway,
        _ tokensStorage: TokensStorageGateway
    ) {
        self.authGateway = authGateway
        self.tokensStorageGateway = tokensStorage
    }
    
    public func perform(credentials: Credentials) -> AnyPublisher<Void, Error> {
        authGateway
            .authorize(credentials: credentials)
            .flatMap(maxPublishers: .max(1), tokensStorageGateway.save)
            .eraseToAnyPublisher()
    }
    
    public func deauth() -> AnyPublisher<Void, Error> {
        tokensStorageGateway.remove()
    }
    
    public func state() -> AnyPublisher<AuthorizationState, Error> {
        tokensStorageGateway
            .get()
            .map { $0.map { _ in .authorized } ?? .notAuthorized }
            .eraseToAnyPublisher()
    }
}

public enum AuthorizationState {
    case authorized
    case notAuthorized
    
    public var isAuthorized: Bool {
        guard case .authorized = self else {
            return false
        }
        
        return true
    }
}
