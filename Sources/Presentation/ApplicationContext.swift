//
//  ApplicationContext.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 12.04.2020.
//

import Foundation
import UIKit
import Domain
import Combine
import Library

public final class ApplicationContext {
    private var bag = Set<AnyCancellable>()

    public var window: UIWindow? {
        didSet {
            launchApp()
        }
    }

    public let useCasesFactory: UseCasesFactory
    public let validatorsFactory: ValidatorsFactory

    private let screensFactories: () -> ScreensFactories

    public init(
        useCasesFactory: UseCasesFactory,
        validatorsFactory: ValidatorsFactory,
        screensFactories: @escaping () -> ScreensFactories
    ) {
        self.useCasesFactory = useCasesFactory
        self.validatorsFactory = validatorsFactory
        self.screensFactories = screensFactories
    }

    private lazy var flowSwitcherViewController = FlowSwitcherViewController(placeholderViewController: .init())

    private func launchApp() {
        window?.rootViewController = flowSwitcherViewController

        useCasesFactory
            .makeAuthorizationUseCase()
            .state()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in }
            ) { [unowned self] in
                if $0.isAuthorized {
                    self.navigateToMain()
                } else {
                    self.navigateToAuth()
                }
            }
            .store(in: &bag)
    }

    private let authController = WeakOwned<AuthController>()
    private let tabBarController = WeakOwned<UITabBarController>()
    private let mainNavigationController = WeakOwned<UINavigationController>()
    private let mainController = WeakOwned<MainController>()

    public func navigateToMain() {
        guard flowSwitcherViewController.previousVisibleVC == tabBarController.value else {
            flowSwitcherViewController.replace(with: setupTabBarController()) {
                self.tabBarController.value?.selectedViewController = self.mainNavigationController.value
            }

            return
        }

        tabBarController.value?.selectedViewController = mainNavigationController.value
    }

    public func navigateToAuth() {
        flowSwitcherViewController.replace(with: authController.get(or: screensFactories().authFactory.makeScreen()))
    }

    private func setupTabBarController() -> UITabBarController {
        let tabBarController = self.tabBarController.get(or: .init())

        guard let controllers = tabBarController.viewControllers, !controllers.isEmpty else {
            tabBarController.setViewControllers([setupMainNavigationController()], animated: false)

            return tabBarController
        }

        return tabBarController
    }

    private func setupMainNavigationController() -> UINavigationController {
        let mainController = self.mainController.get(or: screensFactories().mainFactory.makeScreen())

        let mainNavigationController = self.mainNavigationController.get(or: .init())

        if mainNavigationController.viewControllers.isEmpty {
            mainNavigationController.setViewControllers([mainController], animated: false)
        }

        return mainNavigationController
    }

    private func get<T: UIViewController>(
        _ kp: ReferenceWritableKeyPath<ApplicationContext, T?>,
        using factory: () -> T
    ) -> T {
        let value: T

        if self[keyPath: kp] == nil {
            value = factory()
            self[keyPath: kp] = value
        } else {
            value = self[keyPath: kp]!
        }

        return value
    }
}
