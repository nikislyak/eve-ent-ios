//
//  Router.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 09.01.2020.
//

import Foundation
import RouteComposer

enum Screen {
    case auth
}

protocol RouterAbstraction {
    func navigate(to screen: Screen)
}

final class RouterAbstractionImpl: RouterAbstraction {
    private let routerImpl: Router
    private let factory: ScreenConfigurationsFactory
    
    init(_ router: Router, _ factory: ScreenConfigurationsFactory) {
        self.routerImpl = router
        self.factory = factory
    }
    
    func navigate(to screen: Screen) {
        switch screen {
        case .auth:
            try? routerImpl.navigate(to: factory.auth, animated: true, completion: nil)
        }
    }
}
