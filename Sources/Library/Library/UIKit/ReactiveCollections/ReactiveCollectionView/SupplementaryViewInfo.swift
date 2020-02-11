//
//  SupplementaryViewInfo.swift
//  Library
//
//  Created by Nikita Kislyakov on 10.02.2020.
//

import Foundation
import UIKit

public struct SupplementaryViewInfo: Equatable {
    public let registrationInfo: ViewRegistrationInfo
    
    public let kind: SupplementaryViewKind
    
    public let accessibilityFormat: SupplementaryAccessibilityFormat
    
    public init(
        registrationInfo: ViewRegistrationInfo,
        kind: SupplementaryViewKind,
        accessibilityFormat: SupplementaryAccessibilityFormat
    ) {
        self.registrationInfo = registrationInfo
        self.kind = kind
        self.accessibilityFormat = accessibilityFormat
    }
}

public enum SupplementaryViewKind: Equatable {
    case header
    case footer
    
    init?(collectionElementKindString: String) {
        switch collectionElementKindString {
        case UICollectionView.elementKindSectionHeader:
            self = .header
        case UICollectionView.elementKindSectionFooter:
            self = .footer
        default:
            return nil
        }
    }
    
    var collectionElementKind: String {
        switch self {
        case .header:
            return UICollectionView.elementKindSectionHeader
        case .footer:
            return UICollectionView.elementKindSectionFooter
        }
    }
}
