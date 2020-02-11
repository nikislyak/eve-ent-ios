//
//  CollectionViewDriver.swift
//  Library
//
//  Created by Nikita Kislyakov on 10.02.2020.
//

import Foundation
import UIKit

public class CollectionViewDriver<SectionIDType: Hashable> {
    public typealias ItemIDType = String
    
    public let collectionView: UICollectionView
    
    private var dataSource: UICollectionViewDiffableDataSource<SectionIDType, ItemIDType>!
    
    public private(set) var collectionViewModel: CollectionViewModel<SectionIDType>
    
    private let diffingQueue: DispatchQueue
    
    public init(
        collectionView: UICollectionView,
        collectionViewModel: CollectionViewModel<SectionIDType> = .init(sectionModels: []),
        diffingQoS qos: DispatchQoS = .userInteractive
    ) {
        self.collectionView = collectionView
        self.collectionViewModel = collectionViewModel
        self.diffingQueue = DispatchQueue(label: "CollectionViewDriver.diffingQueue", qos: qos, attributes: .concurrent)
        
        dataSource = .init(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, id in
            guard let self = self else { return nil }
            
            let copy = self.diffingQueue.sync {
                self.collectionViewModel
            }
            
            let cell = copy[ifExists: indexPath].map {
                collectionView.configuredCell(for: $0, at: indexPath)
            }
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }
            
            let copy = self.diffingQueue.sync {
                self.collectionViewModel
            }
            
            let section = indexPath.section
            
            guard
                let elementKind = SupplementaryViewKind(collectionElementKindString: kind),
                let sectionModel = copy[ifExists: section],
                let viewModel = elementKind == .header ? sectionModel.headerViewModel : sectionModel.footerViewModel,
                let identifier = viewModel.viewInfo?.registrationInfo.reuseIdentifier
            else {
                return nil
            }
            
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
            
            viewModel.apply(to: view)
            
            view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifier(for: section)
            
            return view
        }
    }
    
    public func update(
        collectionViewModel: CollectionViewModel<SectionIDType>,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        diffingQueue.async(flags: .barrier) {
            self.collectionViewModel = collectionViewModel
            
            DispatchQueue.main.async {
                let copy = self.diffingQueue.sync {
                    self.collectionViewModel
                }
                
                self.collectionView.registerViews(for: copy)
                
                self.diffingQueue.async {
                    var snapshot = NSDiffableDataSourceSnapshot<SectionIDType, ItemIDType>()
                    
                    snapshot.appendSections(self.collectionViewModel.sectionModels.map { $0.id })
                    
                    for section in self.collectionViewModel.sectionModels {
                        let ids = section.cellViewModels.map { $0.id }
                        
                        snapshot.appendItems(ids, toSection: section.id)
                    }
                    
                    self.dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
                }
            }
        }
    }
}

extension UICollectionView {
    func registerViews<SectionIDType: Hashable>(for model: CollectionViewModel<SectionIDType>) {
        model.sectionModels.forEach {
            register(cellViewModels: $0.cellViewModels)
            
            if let header = $0.headerViewModel {
                register(supplementaryViewModel: header)
            }
            
            if let footer = $0.footerViewModel {
                register(supplementaryViewModel: footer)
            }
        }
    }
    
    func configuredCell(for model: CollectionCellViewModel, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: model.registrationInfo.reuseIdentifier, for: indexPath)
        
        model.apply(to: cell)
        cell.accessibilityIdentifier = model.accessibilityFormat.accessibilityIdentifier(for: indexPath)
        
        return cell
    }
}
