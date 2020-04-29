//
//  UIApplicationLauncher.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 28.04.2020.
//

import Foundation
import UIKit
import Combine
import Library
import Presentation

class BaseApplicationLauncher: ApplicationLauncher {
	let window: UIWindow
	let applicationContext: ApplicationContext

	init(window: UIWindow, applicationContext: ApplicationContext) {
		self.window = window
		self.applicationContext = applicationContext
	}

	func launch() {
		window.rootViewController = applicationContext.router.flowSwitcherViewController
		window.makeKeyAndVisible()
	}
}

class BaseDecorator: ApplicationLauncher {
	var bag = Set<AnyCancellable>()

	let implementation: ApplicationLauncher
	let applicationContext: ApplicationContext

	init(
		implementation: ApplicationLauncher,
		applicationContext: ApplicationContext
	) {
		self.implementation = implementation
		self.applicationContext = applicationContext
	}

	func launch() {
		implementation.launch()
	}
}

final class CleanStartDecorator: BaseDecorator {
	override func launch() {
		implementation.launch()

		applicationContext
			.useCasesFactory
			.makeAuthorizationUseCase()
			.state()
			.first()
			.receive(on: RunLoop.main)
			.sink(
				receiveCompletion: { _ in }
			) { [applicationContext] in
				if $0.isAuthorized {
					applicationContext.router.navigateToMain()
				} else {
					applicationContext.router.navigateToAuth()
				}
			}
			.store(in: &bag)
	}
}

class ShortcutStartDecorator: BaseDecorator {
	private let item: UIApplicationShortcutItem

	init(
		shortcutItem: UIApplicationShortcutItem,
		implementation: ApplicationLauncher,
		applicationContext: ApplicationContext
	) {
		self.item = shortcutItem

		super.init(implementation: implementation, applicationContext: applicationContext)
	}

	override func launch() {
		implementation.launch()

		handle(shortcutItem: item)
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
