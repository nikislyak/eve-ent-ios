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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let sectionId = UUID().uuidString
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            DispatchQueue.global(qos: .userInitiated).async {
                let sections = [
                    CollectionSectionViewModel(
                        id: sectionId,
                        cellViewModels: (0 ..< Int.random(in: 1 ... 10)).shuffled().map { i in
                            TextCollectionCellViewModel(id: .init(i), text: .init(i))
                        }
                    )
                ]
                
                self?.state.sections = sections
            }
        }
    }
    
    @objc func close() {
        router.navigate(to: .auth)
    }
}
