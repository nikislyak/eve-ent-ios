//
//  GatewaysFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 22.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Domain

public final class GatewaysFactoryImpl: GatewaysFactory {
    private let infrastructureFactory: InfrastructureFactory
    
    public init(_ infrastructureFactory: InfrastructureFactory) {
        self.infrastructureFactory = infrastructureFactory
    }
    
    private lazy var authGateway = AuthorizationGatewayImpl(network: infrastructureFactory.makeNetwork())
    
    public func makeAuthorizationGateway() -> AuthorizationGateway {
        authGateway
    }
    
    private lazy var userPersistence = UserPersistenceGatewayMock()
    
    public func makeUserPersistenceGateway() -> UserPersistenceGateway {
        userPersistence
    }
}
