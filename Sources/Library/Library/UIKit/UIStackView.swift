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
    public func with(_ views: UIView...) -> Self {
        views.forEach(addArrangedSubview)
        
        return self
    }

    @discardableResult
    public func with(_ views: [UIView]) -> Self {
        views.forEach(addArrangedSubview)
        
        return self
    }
}
