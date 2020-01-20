//
//  AuthorizationUseCase.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Combine
import Library

public class AuthorizationStateUseCase {
    var user: AnyPublisher<User?, Error> {
        userSubject.eraseToAnyPublisher()
    }
    
    private var bag = Set<AnyCancellable>()
    
    private let userPersistence: UserPersistenceGateway
    
    private let userSubject = CurrentValueSubject<User?, Error>(nil)
    
    public init(_ userPersistence: UserPersistenceGateway) {
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

public class AuthorizationUseCase {
    private let authGateway: AuthorizationGateway
    private let userPersistence: UserPersistenceGateway
    
    public init(
        _ authGateway: AuthorizationGateway,
        _ userPersistence: UserPersistenceGateway
    ) {
        self.authGateway = authGateway
        self.userPersistence = userPersistence
    }
    
    public func perform(credentials: Credentials) -> AnyPublisher<Void, Error> {
        authGateway
            .authorize(credentials: credentials)
            .flatMapLatest(^\.user >>> userPersistence.set)
            .eraseToAnyPublisher()
    }
    
    public func deauth() -> AnyPublisher<Void, Error> {
        userPersistence.remove()
    }
}
