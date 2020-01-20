//
//  GatewayProtocols.swift
//  Domain
//
//  Created by Nikita Kislyakov on 21.01.2020.
//

import Foundation
import Combine

public protocol UserPersistenceGateway {
    func currentUser() -> AnyPublisher<User?, Error>
    func set(_ currentUser: User) -> AnyPublisher<Void, Error>
    func remove() -> AnyPublisher<Void, Error>
}

public protocol AuthorizationGateway {
    func authorize(credentials: Credentials) -> AnyPublisher<Tokens, Error>
}
