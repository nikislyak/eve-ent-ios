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
    let mainFactory: MainFactory
    
    public init(
        authFactory: AuthFactory,
        mainFactory: MainFactory
    ) {
        self.authFactory = authFactory
        self.mainFactory = mainFactory
    }
}
