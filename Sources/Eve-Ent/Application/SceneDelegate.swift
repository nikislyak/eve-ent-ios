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
import Presentation
import Validation

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private lazy var coreDataFactory = CoreDataFactoryImpl()
    private lazy var infrastructureFactory = InfrastructureFactory(coreDataFactory: coreDataFactory)
    private lazy var gatewaysFactory = GatewaysFactoryImpl(infrastructureFactory)
    private lazy var useCasesFactory = UseCasesFactory(gatewaysFactory)
    private lazy var validatorsFactory = ValidatorsFactoryImpl()
    
    private lazy var authFactory: AuthFactory = makeFactory()
    private lazy var mainFactory: MainFactory = makeFactory()
    
    private lazy var screensFactories = ScreensFactories(
        authFactory: authFactory,
        mainFactory: mainFactory
    )

    private lazy var applicationContext = ApplicationContext(
        useCasesFactory: useCasesFactory,
        validatorsFactory: validatorsFactory,
        screensFactories: { [unowned self] in self.screensFactories }
    )
    
    private func makeFactory<S: UserInterfaceModule, F: BaseScreenFactory<S>>() -> F {
        .init(context: applicationContext)
    }
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            self.window = window
            
            applicationContext.window = window
            
            window.makeKeyAndVisible()
        }
    }
}
