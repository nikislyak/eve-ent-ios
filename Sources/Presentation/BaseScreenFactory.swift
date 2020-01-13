//
//  BaseScreenFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.12.2019.
//

import Foundation
import UIKit

protocol UserInterfaceModule: UIViewController {
    init(useCasesFactory: UseCasesFactory, router: RouterAbstraction)
}

class BaseScreenFactory<S: UserInterfaceModule> {
    let useCasesFactory: UseCasesFactory
    let router: RouterAbstraction
    
    init(useCasesFactory: UseCasesFactory, router: RouterAbstraction) {
        self.useCasesFactory = useCasesFactory
        self.router = router
    }
    
    func makeScreen() -> S {
        S(useCasesFactory: useCasesFactory, router: router)
    }
}
