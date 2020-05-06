//
//  SceneDelegate.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

	private lazy var applicationContext = Dependencies.applicationContext

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
			applicationContext.router.navigateToCamera()
			completionHandler?(true)
		case "main":
			applicationContext.router.navigateToMain()
			completionHandler?(true)
		default:
			return
		}
	}
}
