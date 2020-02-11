//
//  CellContainerViewProtocol.swift
//  Library
//
//  Created by Nikita Kislyakov on 11.02.2020.
//

import Foundation
import UIKit

protocol CellContainerViewProtocol {
    associatedtype CellType: UIView
    associatedtype SupplementaryType: UIView
    
    func dequeueReusableCellFor(identifier: String, indexPath: IndexPath) -> CellType
    
    func dequeueReusableSupplementaryViewFor(kind: SupplementaryViewKind, identifier: String, indexPath: IndexPath) -> SupplementaryType?
    
    func registerCellClass(_ cellClass: AnyClass?, identifier: String)
    func registerCellNib(_ cellNib: UINib?, identifier: String)
    
    func registerSupplementaryClass(_ supplementaryClass: AnyClass?, kind: SupplementaryViewKind, identifier: String)
    func registerSupplementaryNib(_ supplementaryNib: UINib?, kind: SupplementaryViewKind, identifier: String)
}

extension CellContainerViewProtocol {
    func register(cellViewModels: [ReusableCellViewModelProtocol]) {
        cellViewModels.forEach {
            register(cellViewModel: $0)
        }
    }
    
    func register(cellViewModel model: ReusableCellViewModelProtocol) {
        let info = model.registrationInfo
        let identifier = info.reuseIdentifier
        let method = info.registrationMethod
        
        switch method {
        case let .fromClass(classType):
            self.registerCellClass(classType, identifier: identifier)
        case .fromNib:
            self.registerCellNib(method.nib, identifier: identifier)
        }
    }
    
    func register(supplementaryViewModel model: ReusableSupplementaryViewModelProtocol) {
        guard let info = model.viewInfo else { return }
        
        let identifier = info.registrationInfo.reuseIdentifier
        let method = info.registrationInfo.registrationMethod
        let kind = info.kind
        
        switch method {
        case let .fromClass(classType):
            self.registerSupplementaryClass(classType, kind: kind, identifier: identifier)
        case .fromNib:
            self.registerSupplementaryNib(method.nib, kind: kind, identifier: identifier)
        }
    }
}

extension UICollectionView: CellContainerViewProtocol {
    typealias CellType = UICollectionViewCell
    typealias SupplementaryType = UICollectionReusableView
    
    func dequeueReusableCellFor(identifier: String, indexPath: IndexPath) -> CellType {
        dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    func dequeueReusableSupplementaryViewFor(kind: SupplementaryViewKind, identifier: String, indexPath: IndexPath) -> SupplementaryType? {
        dequeueReusableSupplementaryView(ofKind: kind.collectionElementKind, withReuseIdentifier: identifier, for: indexPath)
    }
    
    func registerCellClass(_ cellClass: AnyClass?, identifier: String) {
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    func registerCellNib(_ cellNib: UINib?, identifier: String) {
        register(cellNib, forCellWithReuseIdentifier: identifier)
    }
    
    func registerSupplementaryClass(_ supplementaryClass: AnyClass?, kind: SupplementaryViewKind, identifier: String) {
        register(supplementaryClass, forSupplementaryViewOfKind: kind.collectionElementKind, withReuseIdentifier: identifier)
    }
    
    func registerSupplementaryNib(_ supplementaryNib: UINib?, kind: SupplementaryViewKind, identifier: String) {
        register(supplementaryNib, forSupplementaryViewOfKind: kind.collectionElementKind, withReuseIdentifier: identifier)
    }
}

extension UITableView: CellContainerViewProtocol {
    typealias CellType = UITableViewCell
    typealias SupplementaryType = UITableViewHeaderFooterView
    
    func dequeueReusableCellFor(identifier: String, indexPath: IndexPath) -> CellType {
        dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
    
    func dequeueReusableSupplementaryViewFor(kind: SupplementaryViewKind, identifier: String, indexPath: IndexPath) -> SupplementaryType? {
        dequeueReusableHeaderFooterView(withIdentifier: identifier)
    }
    
    func registerCellClass(_ cellClass: AnyClass?, identifier: String) {
        register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func registerCellNib(_ cellNib: UINib?, identifier: String) {
        register(cellNib, forCellReuseIdentifier: identifier)
    }
    
    func registerSupplementaryClass(_ supplementaryClass: AnyClass?, kind: SupplementaryViewKind, identifier: String) {
        register(supplementaryClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func registerSupplementaryNib(_ supplementaryNib: UINib?, kind: SupplementaryViewKind, identifier: String) {
        register(supplementaryNib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}
