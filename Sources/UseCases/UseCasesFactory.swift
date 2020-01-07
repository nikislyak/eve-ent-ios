//
//  UseCasesFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 22.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

final class UseCasesFactory {
    private let gatewaysFactory: GatewaysFactory
    
    init(_ gatewaysFactory: GatewaysFactory) {
        self.gatewaysFactory = gatewaysFactory
    }
    
    private lazy var auth = AuthorizationUseCase(
        gatewaysFactory.makeAuthorizationGateway(),
        gatewaysFactory.makeUserPersistenceGateway()
    )
    
    private lazy var authState = AuthorizationStateUseCase(
        gatewaysFactory.makeUserPersistenceGateway()
    )
    
    private lazy var editProfile = EditProfileUseCase(
        gatewaysFactory.makeUserPersistenceGateway()
    )
    
    func makeAuthorizationUseCase() -> AuthorizationUseCase {
        auth
    }
    
    func makeAuthorizationStateUseCase() -> AuthorizationStateUseCase {
        authState
    }
    
    func makeEditProfileUseCase() -> EditProfileUseCase {
        editProfile
    }
}
