//
//  UserPersistenceGateway.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 22.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Combine
import CoreData

protocol UserPersistenceGateway {
    func currentUser() -> AnyPublisher<User?, Error>
    func set(_ currentUser: User) -> AnyPublisher<Void, Error>
    func remove() -> AnyPublisher<Void, Error>
}

final class UserPersistenceGatewayMock: UserPersistenceGateway {
    @Published private var user: User?
    
    func currentUser() -> AnyPublisher<User?, Error> {
        $user
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func set(_ currentUser: User) -> AnyPublisher<Void, Error> {
        Result
            .Publisher(())
            .map { [weak self] in self?.user = currentUser }
            .eraseToAnyPublisher()
    }
    
    func remove() -> AnyPublisher<Void, Error> {
        Result
            .Publisher(())
            .map { [weak self] in self?.user = nil }
            .eraseToAnyPublisher()
    }
}
