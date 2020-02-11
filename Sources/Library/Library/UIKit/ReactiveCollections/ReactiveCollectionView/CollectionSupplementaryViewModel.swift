//
//  CollectionSupplementaryViewModel.swift
//  Library
//
//  Created by Nikita Kislyakov on 10.02.2020.
//

import Foundation
import UIKit

public protocol CollectionSupplementaryViewModel: ReusableSupplementaryViewModelProtocol {
    var viewInfo: SupplementaryViewInfo? { get }
    
    var height: CGFloat? { get }
    
    func apply(to view: UICollectionReusableView)
}

extension CollectionSupplementaryViewModel {
    public var viewInfo: SupplementaryViewInfo? { return nil }
    
    public var height: CGFloat? { return nil }
}
