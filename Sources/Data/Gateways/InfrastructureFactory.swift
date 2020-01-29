//
//  InfrastructureFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 25.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import CoreData
import KeychainAccess
import RouteComposer
import Library
import CoreDataKit

public final class InfrastructureFactory {
    private let coreDataFactory: CoreDataFactory
    
    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()
    
    private lazy var appInfo = ApplicationInfo(bundle: .main)
    private lazy var keychain = Keychain()
    private lazy var keychainStorage = KeychainStorage(keychain: keychain, decoder: decoder, encoder: encoder)
    private lazy var userDefaultsStorage = UserDefaultsStorage(userDefaults: .standard, decoder: decoder, encoder: encoder)
    
    private lazy var router: Router = {
        var router = DefaultRouter()
        
        router.add(NavigationDelayingInterceptor())
        
        return router
    }()
    
    public init(coreDataFactory: CoreDataFactory) {
        self.coreDataFactory = coreDataFactory
    }
    
    private lazy var coreDataGateway = CoreDataGateway(
        childContext: coreDataFactory.makeChildManagedObjectContext(),
        container: coreDataFactory.makePersistentContainer()
    )
    
    public func makeCoreDataGateway() -> CoreDataGateway {
        coreDataGateway
    }
    
    public func makeRouter() -> Router {
        router
    }
}
