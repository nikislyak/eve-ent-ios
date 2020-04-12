//
//  CollectionSectionViewModel.swift
//  Library
//
//  Created by Nikita Kislyakov on 10.02.2020.
//

import Foundation
import UIKit

public struct CollectionSectionViewModel<SectionIDType: Hashable> {
    public var cellViewModels: [CollectionCellViewModel]
    
    public var headerViewModel: CollectionSupplementaryViewModel?
    
    public var footerViewModel: CollectionSupplementaryViewModel?
    
    public var id: SectionIDType
    
    public var isEmpty: Bool {
        return cellViewModels.isEmpty
    }
    
    public init(
        id: SectionIDType,
        cellViewModels: [CollectionCellViewModel],
        headerViewModel: CollectionSupplementaryViewModel? = nil,
        footerViewModel: CollectionSupplementaryViewModel? = nil
    ) {
        self.cellViewModels = cellViewModels
        self.headerViewModel = headerViewModel
        self.footerViewModel = footerViewModel
        self.id = id
    }
}

extension CollectionSectionViewModel: Collection {
    public subscript(position: Int) -> CollectionCellViewModel {
        return cellViewModels[position]
    }
    
    public func index(after i: Int) -> Int {
        return cellViewModels.index(after: i)
    }
    
    public var startIndex: Int {
        return cellViewModels.startIndex
    }
    
    public var endIndex: Int {
        return cellViewModels.endIndex
    }
}
