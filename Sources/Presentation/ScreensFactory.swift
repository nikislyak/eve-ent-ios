//
//  ScreensFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.12.2019.
//

import Foundation
import UIKit

public class ScreensFactories {
    public let authFactory: AuthFactory
    public let mainFactory: MainFactory
	public let cameraFactory: CameraFactory
    
    public init(
        authFactory: AuthFactory,
        mainFactory: MainFactory,
		cameraFactory: CameraFactory
    ) {
        self.authFactory = authFactory
        self.mainFactory = mainFactory
		self.cameraFactory = cameraFactory
    }
}
