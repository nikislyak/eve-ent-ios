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
import Networking
import Combine

public final class InfrastructureFactory {
    private let coreDataFactory: CoreDataFactory
    
    private lazy var decoder = JSONDecoder() |> \.keyDecodingStrategy .~ .convertFromSnakeCase
    private lazy var encoder = JSONEncoder() |> \.keyEncodingStrategy .~ .convertToSnakeCase
    
    private lazy var appInfo = ApplicationInfo(bundle: .main)
    private lazy var keychain = Keychain()
    private lazy var keychainStorage = KeychainStorage(keychain: keychain, decoder: decoder, encoder: encoder)
    private lazy var userDefaultsStorage = UserDefaultsStorage(userDefaults: .standard, decoder: decoder, encoder: encoder)
    
    private lazy var router: Router = {
        var router = DefaultRouter()
        
        router.add(NavigationDelayingInterceptor())
        
        return router
    }()
    
    private lazy var network = Network(
        env: Network.Environment(
            urlSession: URLSession.shared,
            baseUrl: URL(string: "https://github.com/")!,
            decoder: decoder,
            encoder: encoder,
            retriers: nil
        )
    )
    
    private lazy var authorizedNetwork = AuthorizedNetwork(
        tokensStorage: userDefaultsStorage,
        env: Network.Environment(
            urlSession: URLSession.shared,
            baseUrl: URL(string: "")!,
            decoder: decoder,
            encoder: encoder,
            retriers: .init(
                responseValidator: ResponseValidator(),
                requestRestorer: Restorer(
                    tokensStorage: userDefaultsStorage,
                    network: network
                )
            )
        )
    )
    
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
    
    public func makeNetwork() -> Network {
        network
    }
    
    public func makeTokensStorage() -> Storage {
        userDefaultsStorage
    }
}
