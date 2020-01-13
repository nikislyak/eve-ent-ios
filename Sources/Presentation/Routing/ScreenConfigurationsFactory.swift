//
//  ScreenConfigurationsFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 09.01.2020.
//

import Foundation
import UIKit
import RouteComposer

protocol ScreenConfigurationsFactory {
    var auth: DestinationStep<AuthController, Any?> { get }
}

final class ScreenConfigurationsFactoryImpl: ScreenConfigurationsFactory {
    private let screensFactories: ScreensFactories
    
    init(_ screensFactories: ScreensFactories) {
        self.screensFactories = screensFactories
    }
    
    var auth: DestinationStep<AuthController, Any?> {
        StepAssembly(
            finder: NilFinder<AuthController, Any?>(),
            factory: screensFactories.authFactory
        )
        .using(GeneralAction.replaceRoot())
        .from(GeneralStep.root())
        .assemble()
    }
}
