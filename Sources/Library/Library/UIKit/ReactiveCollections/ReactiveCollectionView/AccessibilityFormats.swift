//
//  AccessibilityFormats.swift
//  Library
//
//  Created by Nikita Kislyakov on 10.02.2020.
//

import Foundation

public struct CellAccessibilityFormat: ExpressibleByStringLiteral, Equatable {
    private let format: String
    
    public init(_ format: String) {
        self.format = format
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.format = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.format = value
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.format = value
    }
    
    public func accessibilityIdentifier(for indexPath: IndexPath) -> String {
        format
            .replacingOccurrences(of: "%{section}", with: String(indexPath.section))
            .replacingOccurrences(of: "%{item}", with: String(indexPath.item))
            .replacingOccurrences(of: "%{row}", with: String(indexPath.row))
    }
}

public struct SupplementaryAccessibilityFormat: ExpressibleByStringLiteral, Equatable {
    private let format: String
    
    public init(_ format: String) {
        self.format = format
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.format = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.format = value
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.format = value
    }
    
    public func accessibilityIdentifier(for section: Int) -> String {
        format.replacingOccurrences(of: "%{section}", with: String(section))
    }
}
