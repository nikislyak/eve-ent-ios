//
//  ScreensFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.12.2019.
//

import Foundation
import UIKit

struct ScreensFactories {
    let authFactory: AuthFactory
    
    init(
        authFactory: AuthFactory
    ) {
        self.authFactory = authFactory
    }
}
