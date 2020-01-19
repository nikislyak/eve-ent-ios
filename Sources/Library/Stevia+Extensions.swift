//
//  Stevia+Extensions.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 19.01.2020.
//

import Foundation
import Stevia
import UIKit

extension UIView {
    @discardableResult
    public func stretchToSafeArea(of view: UIView) -> Self {
        Top == view.safeAreaLayoutGuide.Top
        Left == view.safeAreaLayoutGuide.Left
        Right == view.safeAreaLayoutGuide.Right
        Bottom == view.safeAreaLayoutGuide.Bottom
        
        return self
    }
    
    @discardableResult
    public func top(toSafeAreaOf view: UIView, _ const: CGFloat) -> Self {
        Top == view.safeAreaLayoutGuide.Top + const
        
        return self
    }
    
    @discardableResult
    public func left(toSafeAreaOf view: UIView, _ const: CGFloat) -> Self {
        Left == view.safeAreaLayoutGuide.Left + const
        
        return self
    }
    
    @discardableResult
    public func right(toSafeAreaOf view: UIView, _ const: CGFloat) -> Self {
        Right == view.safeAreaLayoutGuide.Right + const
        
        return self
    }
    
    @discardableResult
    public func bottom(toSafeAreaOf view: UIView, _ const: CGFloat) -> Self {
        Bottom == view.safeAreaLayoutGuide.Bottom + const
        
        return self
    }
}
