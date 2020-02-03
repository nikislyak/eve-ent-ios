//
//  MainFactory.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 04.02.2020.
//

import Foundation
import UIKit
import RouteComposer

public final class MainFactory: BaseScreenFactory<MainController> {}

extension MainFactory: Factory {
    public typealias ViewController = MainController
    
    public typealias Context = Any?
    
    public func build(with context: Any?) throws -> MainController {
        makeScreen()
    }
}
