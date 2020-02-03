//
//  UseCasesFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 22.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

public final class UseCasesFactory {
    private let gatewaysFactory: GatewaysFactory
    
    public init(_ gatewaysFactory: GatewaysFactory) {
        self.gatewaysFactory = gatewaysFactory
    }
    
    private lazy var auth = AuthorizationUseCase(
        gatewaysFactory.makeAuthorizationGateway(),
        gatewaysFactory.makeTokensStorageGateway()
    )
    
    public func makeAuthorizationUseCase() -> AuthorizationUseCase {
        auth
    }
}
