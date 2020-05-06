//
//  AppDelegate.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import UIKit
import Domain
import Data
import Validation
import Presentation

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
	private lazy var coreDataFactory = CoreDataFactoryImpl()
	private lazy var infrastructureFactory = InfrastructureFactory(coreDataFactory: coreDataFactory)
	private lazy var gatewaysFactory = GatewaysFactoryImpl(infrastructureFactory)
	private lazy var useCasesFactory = UseCasesFactory(gatewaysFactory)
	private lazy var validatorsFactory = ValidatorsFactoryImpl()

	private lazy var authFactory: AuthFactory = makeFactory()
	private lazy var mainFactory: MainFactory = makeFactory()
	private lazy var cameraFactory: CameraFactory = makeFactory()

	private lazy var screensFactories = ScreensFactories(
		authFactory: authFactory,
		mainFactory: mainFactory,
		cameraFactory: cameraFactory
	)

	private lazy var router = ApplicationRouter { [unowned self] in
		self.screensFactories
	}

	private(set) lazy var applicationContext = ApplicationContext(
		useCasesFactory: useCasesFactory,
		validatorsFactory: validatorsFactory,
		router: router
	)

	private func makeFactory<S: UserInterfaceModule, F: BaseScreenFactory<S>>() -> F {
		.init(context: applicationContext)
	}

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        connectingSceneSession.configuration
    }
}

private extension UIApplication {
	var typedDelegate: AppDelegate {
		delegate as! AppDelegate
	}
}

@dynamicMemberLookup
enum Dependencies {
	static subscript<T>(dynamicMember kp: KeyPath<AppDelegate, T>) -> T {
		UIApplication.shared.typedDelegate[keyPath: kp]
	}
}
