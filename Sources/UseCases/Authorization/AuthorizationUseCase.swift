//
//  AuthorizationUseCase.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Combine

class AuthorizationStateUseCase {
    var user: AnyPublisher<User?, Error> {
        userSubject.eraseToAnyPublisher()
    }
    
    private var bag = Set<AnyCancellable>()
    
    private let userPersistence: UserPersistenceGateway
    
    private let userSubject = CurrentValueSubject<User?, Error>(nil)
    
    init(_ userPersistence: UserPersistenceGateway) {
        self.userPersistence = userPersistence
        
        userPersistence
            .currentUser()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.userSubject.send($0) }
            )
            .store(in: &bag)
    }
}

class AuthorizationUseCase {
    private let authGateway: AuthorizationGateway
    private let userPersistence: UserPersistenceGateway
    
    init(
        _ authGateway: AuthorizationGateway,
        _ userPersistence: UserPersistenceGateway
    ) {
        self.authGateway = authGateway
        self.userPersistence = userPersistence
    }
    
    func perform(credentials: Credentials) -> AnyPublisher<Void, Error> {
        authGateway
            .authorize(credentials: credentials)
            .flatMapLatest(^\.user >>> userPersistence.set)
            .eraseToAnyPublisher()
    }
    
    func deauth() -> AnyPublisher<Void, Error> {
        userPersistence.remove()
    }
}
