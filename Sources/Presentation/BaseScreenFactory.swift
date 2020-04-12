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
    init(context: ApplicationContext)
}

public class BaseScreenFactory<S: UserInterfaceModule> {
    public let context: ApplicationContext
    
    public required init(context: ApplicationContext) {
        self.context = context
    }
    
    public func makeScreen() -> S {
        S(context: context)
    }
}
