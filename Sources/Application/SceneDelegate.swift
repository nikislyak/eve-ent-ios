//
//  SceneDelegate.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private lazy var infrastructureFactory = InfrastructureFactory()
    private lazy var gatewaysFactory = GatewaysMockFactory(infrastructureFactory)
    private lazy var useCasesFactory = UseCasesFactory(gatewaysFactory)
    
    private lazy var screensFactory = ScreensFactory()
    private lazy var screenConfigurationsFactory = ScreenConfigurationsFactoryImpl(screensFactory)
    
    private lazy var router: RouterAbstraction = RouterAbstractionImpl(infrastructureFactory.makeRouter(), screenConfigurationsFactory)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            self.window = window
            
            window.makeKeyAndVisible()
            
            router.navigate(to: .auth)
        }
    }
}
