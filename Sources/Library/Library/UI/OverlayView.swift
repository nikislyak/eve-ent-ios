//
//  OverlayView.swift
//  Library
//
//  Created by Nikita Kislyakov on 19.04.2020.
//

import Foundation
import UIKit

open class OverlayView: UIView {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view == self {
            return nil
        } else {
            return view
        }
    }
}
