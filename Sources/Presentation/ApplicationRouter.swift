//
//  ApplicationRouter.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 28.04.2020.
//

import Foundation
import UIKit
import Library

protocol ScreenBuilder {
	func build() -> UIViewController
}

class ContainerControllerBuilder<C: UIViewController> {
	let containerController = WeakOwned<C>()

	let dependenciesBuilders: [ScreenBuilder]

	init(dependenciesBuilders: [ScreenBuilder]) {
		self.dependenciesBuilders = dependenciesBuilders
	}
}

final class TabBarControllerBuilder: ContainerControllerBuilder<UITabBarController>, ScreenBuilder {
	func build() -> UIViewController {
		let tabBarController = self.containerController.get(or: .init())

		let dependencies = dependenciesBuilders.map { $0.build() }

		guard
			let controllers = tabBarController.viewControllers,
			dependencies == controllers
		else {
			tabBarController.setViewControllers(
				dependencies,
				animated: false
			)

			return tabBarController
		}

		return tabBarController
	}
}

final class NavigationControllerBuilder: ContainerControllerBuilder<UINavigationController>, ScreenBuilder {
	func build() -> UIViewController {
		let navigationController = self.containerController.get(or: .init())

		if navigationController.viewControllers.isEmpty {
			navigationController.setViewControllers(
				dependenciesBuilders.map { $0.build() },
				animated: false
			)
		}

		return navigationController
	}
}

class FactoryScreenBuilder<S: UserInterfaceModule, F: BaseScreenFactory<S>>: ScreenBuilder {
	private let screensFactories: () -> ScreensFactories

	private let screen = WeakOwned<S>()

	private let keyPath: KeyPath<ScreensFactories, F>

	init(
		_ screensFactories: @escaping () -> ScreensFactories,
		keyPath: KeyPath<ScreensFactories, F>
	) {
		self.screensFactories = screensFactories
		self.keyPath = keyPath
	}

	func build() -> UIViewController {
		screen.get(or: screensFactories()[keyPath: keyPath].makeScreen())
	}
}

public final class ApplicationRouter {
	private let screensFactories: () -> ScreensFactories

	public private(set) lazy var flowSwitcherViewController = FlowSwitcherViewController(placeholderViewController: .init())

	private lazy var authControllerBuilder = FactoryScreenBuilder(screensFactories, keyPath: \.authFactory)
	private lazy var cameraControllerBuilder = FactoryScreenBuilder(screensFactories, keyPath: \.cameraFactory)
	private lazy var mainControllerBuilder = FactoryScreenBuilder(screensFactories, keyPath: \.mainFactory)
	private lazy var tabBarControllerBuilder = TabBarControllerBuilder(
		dependenciesBuilders: [
			mainNavigationControllerBuilder,
			cameraNavigationControllerBuilder
		]
	)
	private lazy var mainNavigationControllerBuilder = NavigationControllerBuilder(
		dependenciesBuilders: [
			mainControllerBuilder
		]
	)
	private lazy var cameraNavigationControllerBuilder = NavigationControllerBuilder(
		dependenciesBuilders: [
			cameraControllerBuilder
		]
	)

	public init(_ screensFactories: @escaping () -> ScreensFactories) {
		self.screensFactories = screensFactories
	}

	public func navigateToMain() {
		selectInTabBarViewController(mainNavigationControllerBuilder.build())
	}

	public func navigateToAuth() {
		flowSwitcherViewController.replace(with: authControllerBuilder.build())
	}

	public func navigateToCamera() {
		selectInTabBarViewController(cameraNavigationControllerBuilder.build())
	}

	private func selectInTabBarViewController(_ vc: UIViewController) {
		let tabBarController = tabBarControllerBuilder.build() as! UITabBarController

		guard
			let previousVC = flowSwitcherViewController.previousVisibleVC,
			previousVC == tabBarController
		else {
			flowSwitcherViewController.replace(with: tabBarController) {
				tabBarController.selectedViewController = vc
			}

			return
		}

		tabBarController.selectedViewController = vc
	}
}
