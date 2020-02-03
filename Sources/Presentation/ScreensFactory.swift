//
//  ScreensFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.12.2019.
//

import Foundation
import UIKit

public struct ScreensFactories {
    let authFactory: AuthFactory
    
    public init(
        authFactory: AuthFactory
    ) {
        self.authFactory = authFactory
    }
}
