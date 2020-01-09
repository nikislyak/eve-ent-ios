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
    var auth: DestinationStep<UIViewController, Any?> { get }
}

final class ScreenConfigurationsFactoryImpl: ScreenConfigurationsFactory {
    private let screensFactory: ScreensFactory
    
    init(_ screensFactory: ScreensFactory) {
        self.screensFactory = screensFactory
    }
    
    var auth: DestinationStep<UIViewController, Any?> {
        StepAssembly(
            finder: NilFinder<UIViewController, Any?>(),
            factory: ClassFactory()
        )
        .using(GeneralAction.replaceRoot())
        .from(GeneralStep.root())
        .assemble()
    }
}
