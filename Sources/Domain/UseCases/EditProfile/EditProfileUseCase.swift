//
//  EditProfileUseCase.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 14.12.2019.
//

import Foundation
import Combine

public final class EditProfileUseCase {
    private let gateway: UserPersistenceGateway
    
    public init(_ gateway: UserPersistenceGateway) {
        self.gateway = gateway
    }
    
    public func perform(newUser user: User) -> AnyPublisher<Void, Error> {
        gateway.set(user)
    }
}
