//
//  AuthorizationGateway.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Combine

protocol AuthorizationGateway {
    func authorize(credentials: Credentials) -> AnyPublisher<Tokens, Error>
}

class AuthorizationGatewayMock: AuthorizationGateway {
    func authorize(credentials: Credentials) -> AnyPublisher<Tokens, Error> {
        let tokens = Tokens(
            accessToken: "",
            refreshToken: "",
            user: .init(
                id: .zero,
                firstName: "Ivan",
                lastName: "Urgant",
                avatarUrl: URL(string: "https://24smi.org/public/media/resize/800x-/celebrity/2017/06/29/WiR3chxn7Xru_ivan-urgant.jpg")
            )
        )
        
        return Result
            .Publisher(tokens)
            .eraseToAnyPublisher()
    }
}
