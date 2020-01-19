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
}
