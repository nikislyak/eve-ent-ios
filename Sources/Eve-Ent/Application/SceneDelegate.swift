//
//  SceneDelegate.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import UIKit
import Combine
import Data
import Domain

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private lazy var coreDataFactory = CoreDataFactoryImpl()
    private lazy var infrastructureFactory = InfrastructureFactory(coreDataFactory: coreDataFactory)
    private lazy var gatewaysFactory = GatewaysFactoryImpl(infrastructureFactory)
    private lazy var useCasesFactory = UseCasesFactory(gatewaysFactory)
    
    private lazy var authFactory = AuthFactory(useCasesFactory: useCasesFactory, router: _router)
    
    private lazy var screensFactories = ScreensFactories(authFactory: authFactory)
    private lazy var screenConfigurationsFactory = ScreenConfigurationsFactoryImpl(screensFactories)
    
    private lazy var _router = RouterAbstractionImpl(infrastructureFactory.makeRouter())
    private var router: RouterAbstraction {
        _router.factory = screenConfigurationsFactory
        
        return _router
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            self.window = window
            
            self.window?.rootViewController = .init()
            
            window.makeKeyAndVisible()
            
            router.navigate(to: .auth)
        }
    }
}
