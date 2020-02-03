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
}
