//
//  CollectionCellViewModel.swift
//  Library
//
//  Created by Nikita Kislyakov on 10.02.2020.
//

import Foundation
import UIKit

public protocol CollectionCellViewModel: ReusableCellViewModelProtocol {
    var id: String { get }
    
    var accessibilityFormat: CellAccessibilityFormat { get }
    
    var shouldHighlight: Bool { get }
    
    var didSelect: DidSelectClosure? { get }
    
    var didDeselect: DidDeselectClosure? { get }
    
    func apply(to cell: UICollectionViewCell)
}

extension CollectionCellViewModel {
    public var shouldHighlight: Bool { return true }
    
    public var didSelect: DidSelectClosure? { return nil }
    
    public var didDeselect: DidDeselectClosure? { return nil }
}
