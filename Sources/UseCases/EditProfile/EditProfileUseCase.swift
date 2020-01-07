//
//  EditProfileUseCase.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 14.12.2019.
//

import Foundation
import Combine

final class EditProfileUseCase {
    private let gateway: UserPersistenceGateway
    
    init(_ gateway: UserPersistenceGateway) {
        self.gateway = gateway
    }
    
    func perform(newUser user: User) -> AnyPublisher<Void, Error> {
        gateway.set(user)
    }
}
