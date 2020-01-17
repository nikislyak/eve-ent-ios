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

enum PersistentModule {
    case container(NSPersistentContainer)
    case coordinator(NSPersistentStoreCoordinator)
    
    var container: NSPersistentContainer? {
        guard case let .container(container) = self else { return nil }
        
        return container
    }
    
    var coordinator: NSPersistentStoreCoordinator? {
        guard case let .coordinator(coordinator) = self else { return nil }
        
        return coordinator
    }
}

protocol CoreDataFactory {
    func makeManagedObjectModel() -> NSManagedObjectModel
    func makeChildManagedObjectContext() -> NSManagedObjectContext
    func makePersistentContainer() -> NSPersistentContainer
}

final class CoreDataFactoryImpl: CoreDataFactory {
    private var momUrl: URL {
        Bundle.main.url(forResource: "eve-ent-model", withExtension: "momd")!
    }
    
    private lazy var mom = NSManagedObjectModel(contentsOf: momUrl)!
    
    private lazy var moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    private lazy var pc = with(NSPersistentContainer(name: "eve-ent-container", managedObjectModel: mom)) {
        $0.loadPersistentStores { desc, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func makeManagedObjectModel() -> NSManagedObjectModel {
        mom
    }
    
    func makeChildManagedObjectContext() -> NSManagedObjectContext {
        moc
    }
    
    func makePersistentContainer() -> NSPersistentContainer {
        pc
    }
}

final class InfrastructureFactory {
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
    
    init(coreDataFactory: CoreDataFactory) {
        self.coreDataFactory = coreDataFactory
    }
    
    private lazy var basePersistenceGateway = BasePersistenceGateway(
        childContext: coreDataFactory.makeChildManagedObjectContext(),
        container: coreDataFactory.makePersistentContainer()
    )
    
    func makeBasePersistenceGateway() -> BasePersistenceGateway {
        basePersistenceGateway
    }
    
    func makeRouter() -> Router {
        router
    }
}
