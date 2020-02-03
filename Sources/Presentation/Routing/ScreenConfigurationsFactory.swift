//
//  ScreenConfigurationsFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 09.01.2020.
//

import Foundation
import UIKit
import RouteComposer

public protocol ScreenConfigurationsFactory {
    var auth: DestinationStep<AuthController, Any?> { get }
    var main: DestinationStep<MainController, Any?> { get }
}

public final class ScreenConfigurationsFactoryImpl: ScreenConfigurationsFactory {
    private let screensFactories: ScreensFactories
    
    public init(_ screensFactories: ScreensFactories) {
        self.screensFactories = screensFactories
    }
    
    public var auth: DestinationStep<AuthController, Any?> {
        StepAssembly(
            finder: NilFinder<AuthController, Any?>(),
            factory: screensFactories.authFactory
        )
        .using(GeneralAction.replaceRoot())
        .from(GeneralStep.root())
        .assemble()
    }
    
    public var main: DestinationStep<MainController, Any?> {
        StepAssembly(
            finder: ClassFinder(),
            factory: screensFactories.mainFactory
        )
        .using(UINavigationController.pushAsRoot())
        .from(NavigationControllerStep())
        .using(UITabBarController.add())
        .from(TabBarControllerStep())
        .using(GeneralAction.replaceRoot())
        .from(GeneralStep.root())
        .assemble()
    }
}
