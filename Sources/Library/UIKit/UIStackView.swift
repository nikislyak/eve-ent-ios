//
//  UIStackView.swift
//  Library
//
//  Created by Никита Кисляков on 20/05/2019.
//

import Foundation
import UIKit

extension UIStackView {
    @discardableResult
    public func arranged(_ views: UIView...) -> Self {
        views.forEach { self.addArrangedSubview($0) }
        
        return self
    }

    @discardableResult
    public func arranged(_ views: [UIView]) -> Self {
        views.forEach { self.addArrangedSubview($0) }
        
        return self
    }
}
