//
//  BaseScreenFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.12.2019.
//

import Foundation
import UIKit
import Domain

public protocol UserInterfaceModule: UIViewController {
    init(useCasesFactory: UseCasesFactory, validatorsFactory: ValidatorsFactory, router: RouterAbstraction)
}

public class BaseScreenFactory<S: UserInterfaceModule> {
    let useCasesFactory: UseCasesFactory
    let validatorsFactory: ValidatorsFactory
    let router: RouterAbstraction
    
    public init(
        useCasesFactory: UseCasesFactory,
        validatorsFactory: ValidatorsFactory,
        router: RouterAbstraction
    ) {
        self.useCasesFactory = useCasesFactory
        self.validatorsFactory = validatorsFactory
        self.router = router
    }
    
    public func makeScreen() -> S {
        S(useCasesFactory: useCasesFactory, validatorsFactory: validatorsFactory, router: router)
    }
}
