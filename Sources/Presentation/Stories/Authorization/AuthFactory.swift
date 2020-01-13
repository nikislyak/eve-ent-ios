//
//  AuthFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.01.2020.
//

import Foundation
import UIKit
import RouteComposer

final class AuthFactory: BaseScreenFactory<AuthController> {}

extension AuthFactory: Factory {
    typealias ViewController = AuthController
    
    typealias Context = Any?
    
    func build(with context: Any?) throws -> AuthController {
        makeScreen()
    }
}
