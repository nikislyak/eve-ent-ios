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
import Domain

public class AuthorizedNetwork: Network {
    private let tokensStorage: Storage
    
    public init(tokensStorage: Storage, env: Environment) {
        self.tokensStorage = tokensStorage
        
        super.init(env: env)
    }
    
    override public func modify(request: RequestBuilder) -> RequestBuilder {
        tokensStorage
            .getObject(forKey: "tokens")
            .flatMap { $0 as Tokens? }
            .map {
                request.header(key: "Authorization", value: "Bearer " + $0.accessToken)
            } ?? request
    }
}
