//
//  AuthorizationGateway.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Combine
import Domain
import Networking

public class AuthorizationGatewayImpl: AuthorizationGateway {
    private let network: Network
    
    public init(network: Network) {
        self.network = network
    }
    
    public func authorize(credentials: Credentials) -> AnyPublisher<Tokens, Error> {
        network
            .request(path: "auth/", encoding: JSONEncoding())
            .method(.POST)
            .param(key: "email", value: credentials.email.value)
            .param(key: "password", value: credentials.password.value)
            .perform()
    }
}
