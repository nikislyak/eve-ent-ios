//
//  MainController.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 04.02.2020.
//

import Foundation
import UIKit
import Combine
import Library

public class MainController: BaseController<MainRootView> {
    override func setup() {
        super.setup()
        
        navigationItem.title = "Main"
        tabBarItem.title = "Main"
        tabBarItem.image = UIImage(systemName: "circle.grid.3x3.fill")
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(close))
    }
    
    @objc func close() {
        router.navigate(to: .auth)
    }
}
