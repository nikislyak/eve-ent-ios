//
//  KeyboardManager.swift
//  Library
//
//  Created by Никита Кисляков on 25/07/2019.
//

import Foundation
import UIKit
import Combine

public protocol KeyboardManagable: UIViewController {
    var managedScrollView: UIScrollView { get }
    var mostBottomView: UIView? { get }
}

private extension Notification {
    var willHide: Bool {
        name == UIResponder.keyboardWillHideNotification
    }
}

open class KeyboardManager {
    private var bag = Set<AnyCancellable>()
    
    public unowned var viewController: KeyboardManagable! {
        didSet {
            guard viewController != nil else {
                return
            }
            
            configureFeedback().store(in: &bag)
        }
    }
    
    public required init() {}
    
    private func configureFeedback() -> [AnyCancellable] {
        [
            Publishers
                .CombineLatest(
                    Publishers
                        .Merge(
                            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                        ),
                        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
                )
                .removeDuplicates { $0.0.willHide == $1.0.willHide }
                .sink { [weak self] showHide, changeFrame in
                    self?.handle(showHide: showHide, changeFrame: changeFrame)
                }
        ]
    }
    
    private func handle(showHide: Notification, changeFrame: Notification) {
        let willHide = showHide.willHide
        let animationData = extractAnimationData(from: changeFrame)
        
        onKeyboardFrameChange(willHide: willHide, animationData: animationData)
    }
    
    public struct AnimationData {
        public let duration: Double
        public let options: UIView.AnimationOptions
        public let beginFrame: CGRect
        public let endFrame: CGRect
    }
    
    private func extractAnimationData(from notification: Notification) -> AnimationData {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let beginFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        return .init(
            duration: duration,
            options: .init(rawValue: curve),
            beginFrame: beginFrame,
            endFrame: endFrame
        )
    }
    
    open func onKeyboardFrameChange(willHide: Bool, animationData: AnimationData) {}
}

open class ScrollViewInsetAdjustingKeyboardManager: KeyboardManager {
    open override func onKeyboardFrameChange(willHide: Bool, animationData: KeyboardManager.AnimationData) {
        adjustContentInset(
            on: viewController.view,
            willHide: willHide,
            animationData: animationData
        )
        
        adjustContentOffset(
            on: viewController.view,
            willHide: willHide,
            animationData: animationData
        )
    }
    
    private func adjustContentInset(
        on view: UIView,
        willHide: Bool,
        animationData: AnimationData
    ) {
        let scrollView = viewController.managedScrollView
        
        let oldInset = scrollView.contentInset
        
        if willHide {
            scrollView.contentInset = .init(
                top: oldInset.top,
                left: oldInset.left,
                bottom: oldInset.bottom - animationData.endFrame.height,
                right: oldInset.right
            )
        } else {
            scrollView.contentInset = .init(
                top: oldInset.top,
                left: oldInset.left,
                bottom: oldInset.bottom + animationData.endFrame.height,
                right: oldInset.right
            )
        }
    }
    
    private func adjustContentOffset(
        on view: UIView,
        willHide: Bool,
        animationData: AnimationData
    ) {
        guard let mostBottomView = viewController.mostBottomView else {
            return
        }
        
        let scrollView = viewController.managedScrollView
        
        if !willHide {
            let mostBottomViewConvertedFrame = view.convert(mostBottomView.frame, from: mostBottomView)
            
            if animationData.endFrame.contains(mostBottomViewConvertedFrame) {
                UIView.animate(
                    withDuration: animationData.duration,
                    delay: 0,
                    options: animationData.options,
                    animations: {
                        scrollView.contentOffset = .init(
                            x: 0,
                            y: scrollView.convert(mostBottomView.frame, from: mostBottomView).origin.y + 8
                        )
                    }
                )
            }
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
}

open class SafeAreaAdjustingKeyboardManager: KeyboardManager {
    open override func onKeyboardFrameChange(willHide: Bool, animationData: KeyboardManager.AnimationData) {
        let old = viewController.additionalSafeAreaInsets
        
        viewController.additionalSafeAreaInsets = .init(
            top: old.top,
            left: old.left,
            bottom: willHide ? 0 : animationData.endFrame.height,
            right: old.right
        )
        
        UIView.animate(
            withDuration: animationData.duration,
            delay: 0,
            options: animationData.options,
            animations: {
                self.viewController.view.layoutIfNeeded()
            }
        )
    }
}
