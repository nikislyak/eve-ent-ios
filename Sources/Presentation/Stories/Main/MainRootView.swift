//
//  MainRootView.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 04.02.2020.
//

import Foundation
import UIKit
import Library
import Stevia

class ChessOrderGridCollectionViewLayout: UICollectionViewLayout {
    
}

public class MainRootView: BaseView {
    private(set) lazy var layout = UICollectionViewFlowLayout() |> \.itemSize .~ .init(width: 100, height: 44)
    private(set) lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private lazy var driver = CollectionViewDriver<String>(collectionView: collectionView)
    
    override func setup() {
        super.setup()
        
        sv(collectionView)
        
        collectionView.fillContainer()
    }
}

extension MainRootView: StateDriven {
    public struct State: EmptyInitializable {
        var sections: [CollectionSectionViewModel<String>] = []
        
        public init() {}
    }
    
    public func render(_ state: State) {
        driver.update(collectionViewModel: .init(sectionModels: state.sections)) 
    }
}

struct TextCollectionCellViewModel: CollectionCellViewModel {
    var id: String = UUID().uuidString
    
    var text: String
    
    var accessibilityFormat: CellAccessibilityFormat {
        .init(String(describing: Self.self))
    }
    
    func apply(to cell: UICollectionViewCell) {
        guard let cell = cell as? TextCollectionViewCell else {
            return
        }
        
        cell.apply(viewModel: self)
    }
    
    var registrationInfo: ViewRegistrationInfo {
        .init(classType: TextCollectionViewCell.self)
    }
}

class TextCollectionViewCell: BaseCollectionViewCell {
    private let label = UILabel()
    
    override func setup() {
        super.setup()
        
        sv(label)
        
        label.centerInContainer()
    }
    
    func apply(viewModel: TextCollectionCellViewModel) {
        label.text = viewModel.text
    }
}
