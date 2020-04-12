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

    private func launchApp() {
        useCasesFactory
            .makeAuthorizationUseCase()
            .state()
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

    private weak var authController: AuthController?
    private weak var tabBarController: UITabBarController?
    private weak var mainNavigationController: UINavigationController?
    private weak var mainController: MainController?

    public func navigateToMain() {
        defer {
            tabBarController?.selectedViewController = mainNavigationController!
        }

        guard window?.rootViewController == tabBarController else {
            window?.rootViewController = setupTabBarController()
            return
        }
    }

    public func navigateToAuth() {
        window?.rootViewController = get(\.authController, using: screensFactories().authFactory.makeScreen)
    }

    private func setupTabBarController() -> UITabBarController {
        let tabBarController = get(\.tabBarController, using: UITabBarController.init)

        guard let controllers = tabBarController.viewControllers, !controllers.isEmpty else {
            tabBarController.setViewControllers([setupMainNavigationController()], animated: false)

            return tabBarController
        }

        return tabBarController
    }

    private func setupMainNavigationController() -> UINavigationController {
        let mainController = get(\.mainController, using: screensFactories().mainFactory.makeScreen)

        let mainNavigationController = get(\.mainNavigationController, using: UINavigationController.init)

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
