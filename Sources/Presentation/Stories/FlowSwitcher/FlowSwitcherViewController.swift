//
//  FlowSwitcherViewController.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 14.04.2020.
//

import Foundation
import UIKit
import Stevia

final class FlowSwitcherViewController: UIViewController {
    private let placeholderViewController: UIViewController

    init(
        placeholderViewController: UIViewController
    ) {
        self.placeholderViewController = placeholderViewController

        super.init(nibName: nil, bundle: nil)
        
        embed(placeholderViewController)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private(set) var previousVisibleVC: UIViewController?

    func replace(with vc: UIViewController, completion: (() -> Void)? = nil) {
        let oldVC: UIViewController

        if let previousVisibleVC = previousVisibleVC {
            oldVC = previousVisibleVC
        } else {
            oldVC = placeholderViewController
        }

        oldVC.willMove(toParent: nil)

        addChild(vc)

        let oldViewEndFrame: CGRect
        let newViewStartFrame: CGRect

        if oldVC == placeholderViewController {
            oldViewEndFrame = oldVC.view.frame
            newViewStartFrame = oldVC.view.frame
        } else {
            oldViewEndFrame = oldVC.view.frame.offsetBy(dx: oldVC.view.frame.width, dy: 0)

            newViewStartFrame = oldVC.view.frame.offsetBy(dx: -oldVC.view.frame.width, dy: 0)
        }

        vc.view.frame = newViewStartFrame
        let newViewEndFrame = oldVC.view.frame

        transition(
            from: oldVC,
            to: vc,
            duration: 0.5,
            options: .curveEaseInOut,
            animations: {
                vc.view.frame = newViewEndFrame
                oldVC.view.frame = oldViewEndFrame
            },
            completion: { _ in
                oldVC.removeFromParent()
                self.previousVisibleVC = vc
                vc.didMove(toParent: self)

                completion?()
            }
        )
    }
}

extension UIViewController {
    func embed(_ vc: UIViewController) {
        addChild(vc)
        view.sv(vc.view)
        vc.view.fillContainer()
        vc.didMove(toParent: self)
    }
}

class FlowSwitcherTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    }
}
