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
