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
	private lazy var cameraFactory: CameraFactory = makeFactory()

	private lazy var screensFactories = ScreensFactories(
		authFactory: authFactory,
		mainFactory: mainFactory,
		cameraFactory: cameraFactory
	)

	private lazy var router = ApplicationRouter { [unowned self] in
		self.screensFactories
	}

	private lazy var applicationContext = ApplicationContext(
		useCasesFactory: useCasesFactory,
		validatorsFactory: validatorsFactory,
		router: router
	)

	private func makeFactory<S: UserInterfaceModule, F: BaseScreenFactory<S>>() -> F {
		.init(context: applicationContext)
	}

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
		guard let windowScene = scene as? UIWindowScene else { return }

		let window = UIWindow(windowScene: windowScene)

		self.window = window
		
		let applicationLauncher = BaseApplicationLauncher(window: window, applicationContext: applicationContext)
		let decoratedApplicationLauncher: ApplicationLauncher

		if let shortcutItem = connectionOptions.shortcutItem {
			decoratedApplicationLauncher = ShortcutStartDecorator(
				shortcutItem: shortcutItem,
				implementation: applicationLauncher,
				applicationContext: applicationContext
			)
		} else {
			decoratedApplicationLauncher = CleanStartDecorator(
				implementation: applicationLauncher,
				applicationContext: applicationContext
			)
		}

		decoratedApplicationLauncher.launch()
    }

	func windowScene(
		_ windowScene: UIWindowScene,
		performActionFor shortcutItem: UIApplicationShortcutItem,
		completionHandler: @escaping (Bool) -> Void
	) {
		handle(shortcutItem: shortcutItem, completionHandler: completionHandler)
	}

	private func handle(
		shortcutItem: UIApplicationShortcutItem,
		completionHandler: ((Bool) -> Void)? = nil
	) {
		switch shortcutItem.type {
		case "camera":
			router.navigateToCamera()
			completionHandler?(true)
		case "main":
			router.navigateToMain()
			completionHandler?(true)
		default:
			return
		}
	}
}
