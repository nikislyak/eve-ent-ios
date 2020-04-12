//
//  CollectionViewModel.swift
//  Library
//
//  Created by Nikita Kislyakov on 10.02.2020.
//

import Foundation
import UIKit

public struct CollectionViewModel<SectionIDType: Hashable> {
    public var sectionModels: [CollectionSectionViewModel<SectionIDType>]
    
    public var isEmpty: Bool {
        return sectionModels.allSatisfy { $0.isEmpty }
    }
    
    public init(sectionModels: [CollectionSectionViewModel<SectionIDType>]) {
        self.sectionModels = sectionModels
    }
    
    public subscript(ifExists section: Int) -> CollectionSectionViewModel<SectionIDType>? {
        guard sectionModels.count > section else { return nil }
        
        return sectionModels[section]
    }
    
    public subscript(ifExists indexPath: IndexPath) -> CollectionCellViewModel? {
        guard
            let section = self[ifExists: indexPath.section],
            section.cellViewModels.count > indexPath.item
        else {
            return nil
        }
        
        return section.cellViewModels[indexPath.item]
    }
}
