//
//  AuthFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.01.2020.
//

import Foundation
import UIKit
import RouteComposer

public final class AuthFactory: BaseScreenFactory<AuthController> {}

extension AuthFactory: Factory {
    public typealias ViewController = AuthController
    
    public typealias Context = Any?
    
    public func build(with context: Any?) throws -> AuthController {
        makeScreen()
    }
}
