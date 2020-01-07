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

final class InfrastructureFactory {
    private var momUrl: URL {
        Bundle.main.url(forResource: "eve-ent-model", withExtension: "momd")!
    }
    
    private lazy var moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    private lazy var mom = NSManagedObjectModel(contentsOf: momUrl)!
    private lazy var container = NSPersistentContainer(name: "eve-ent-container", managedObjectModel: mom)
    
    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()
    
    private lazy var appInfo = ApplicationInfo(bundle: .main)
    private lazy var keychain = Keychain()
    private lazy var keychainStorage = KeychainStorage(keychain: keychain, decoder: decoder, encoder: encoder)
    private lazy var userDefaultsStorage = UserDefaultsStorage(userDefaults: .standard, decoder: decoder, encoder: encoder)
    
    func makeMOC() -> NSManagedObjectContext {
        moc
    }
    
    func makeMOM() -> NSManagedObjectModel {
        mom
    }
    
    func makePersistentContainer() -> NSPersistentContainer {
        container
    }
}
