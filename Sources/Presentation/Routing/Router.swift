//
//  Router.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 09.01.2020.
//

import Foundation
import RouteComposer

public enum Screen {
    case auth
}

public protocol RouterAbstraction {
    func navigate(to screen: Screen)
}

public final class RouterAbstractionImpl: RouterAbstraction {
    private let routerImpl: Router
    public var factory: ScreenConfigurationsFactory!
    
    public init(_ router: Router) {
        self.routerImpl = router
    }
    
    public func navigate(to screen: Screen) {
        switch screen {
        case .auth:
            try? routerImpl.navigate(to: factory.auth, animated: true, completion: nil)
        }
    }
}
