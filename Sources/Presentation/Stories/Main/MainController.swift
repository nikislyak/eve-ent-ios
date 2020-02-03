//
//  MainController.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 04.02.2020.
//

import Foundation
import UIKit
import Combine

public class MainController: BaseController<MainRootView> {
    override func setup() {
        super.setup()
        
        navigationItem.title = "Main"
        tabBarItem.title = "Main"
        tabBarItem.image = UIImage(systemName: "circle.grid.3x3.fill")
    }
}
