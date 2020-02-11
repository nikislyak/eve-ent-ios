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
        diffingQueue: DispatchQueue = .global(qos: .userInteractive)
    ) {
        self.collectionView = collectionView
        self.collectionViewModel = collectionViewModel
        self.diffingQueue = diffingQueue
        
        dataSource = .init(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, id in
            self?.collectionViewModel[ifExists: indexPath].map {
                collectionView.configuredCell(for: $0, at: indexPath)
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let section = indexPath.section
            let elementKind = SupplementaryViewKind(collectionElementKindString: kind)
            let view: UICollectionReusableView
            
            if let elementKind = elementKind,
                let sectionModel = self?.collectionViewModel[ifExists: section],
                let viewModel = elementKind == .header ? sectionModel.headerViewModel : sectionModel.footerViewModel,
                let identifier = viewModel.viewInfo?.registrationInfo.reuseIdentifier {
                view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
                
                viewModel.apply(to: view)
                
                view.accessibilityIdentifier = viewModel.viewInfo?.accessibilityFormat.accessibilityIdentifier(for: section)
            } else {
                view = UICollectionReusableView()
            }
            
            return view
        }
    }
    
    private let lock = NSRecursiveLock()
    
    public func update(
        collectionViewModel: CollectionViewModel<SectionIDType>,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        self.collectionViewModel = collectionViewModel
        
        collectionView.registerViews(for: self.collectionViewModel)
        
        diffingQueue.async { [weak self] in
            guard let self = self else { return }
            
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
