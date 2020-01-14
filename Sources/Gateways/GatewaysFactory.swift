//
//  GatewaysFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 22.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

protocol GatewaysFactory {
    func makeAuthorizationGateway() -> AuthorizationGateway
    func makeUserPersistenceGateway() -> UserPersistenceGateway
}

final class GatewaysMockFactory: GatewaysFactory {
    private let infrastructureFactory: InfrastructureFactory
    
    init(_ infrastructureFactory: InfrastructureFactory) {
        self.infrastructureFactory = infrastructureFactory
    }
    
    private lazy var basePersistenceGateway = BasePersistenceGateway(
        infrastructureFactory.makeMOC(),
        infrastructureFactory.makePersistentContainer()
    )
    
    private lazy var authGateway = AuthorizationGatewayMock()
    
    func makeAuthorizationGateway() -> AuthorizationGateway {
        authGateway
    }
    
    func makeBasePersistenceGateway() -> BasePersistenceGateway {
        basePersistenceGateway
    }
    
    private lazy var userPersistence = UserPersistenceGatewayMock()
    
    func makeUserPersistenceGateway() -> UserPersistenceGateway {
        userPersistence
    }
}
