//
//  GatewayProtocols.swift
//  Domain
//
//  Created by Nikita Kislyakov on 21.01.2020.
//

import Foundation
import Combine

public protocol AuthorizationGateway {
    func authorize(credentials: Credentials) -> AnyPublisher<Tokens, Error>
}

public protocol TokensStorageGateway {
    func get() -> AnyPublisher<Tokens?, Error>
    func save(_ tokens: Tokens) -> AnyPublisher<Void, Error>
    func remove() -> AnyPublisher<Void, Error>
}
