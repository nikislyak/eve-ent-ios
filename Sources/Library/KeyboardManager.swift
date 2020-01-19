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
    var hide: Bool {
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
                .sink { [weak self] showHide, changeFrame in
                    self?.handle(showHide: showHide, changeFrame: changeFrame)
                }
        ]
    }
    
    private func handle(showHide: Notification, changeFrame: Notification) {
        let hide = showHide.hide
        let animationData = extractAnimationData(from: changeFrame)
        
        onKeyboardFrameChange(willHide: hide, animationData: animationData)
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
            hide: willHide,
            animationData: animationData
        )
        
        adjustContentOffset(
            on: viewController.view,
            hide: willHide,
            animationData: animationData
        )
    }
    
    private lazy var initialInset = viewController.managedScrollView.contentInset
    
    private func adjustContentInset(
        on view: UIView,
        hide: Bool,
        animationData: AnimationData
    ) {
        let scrollView = viewController.managedScrollView
        
        if hide {
            scrollView.contentInset = initialInset
        } else {
            scrollView.contentInset = .init(
                top: initialInset.top,
                left: initialInset.left,
                bottom: initialInset.bottom + animationData.endFrame.height,
                right: initialInset.right
            )
        }
    }
    
    private func adjustContentOffset(
        on view: UIView,
        hide: Bool,
        animationData: AnimationData
    ) {
        guard let mostBottomView = viewController.mostBottomView else {
            return
        }
        
        let scrollView = viewController.managedScrollView
        
        var newVisibleRect = view.frame
        
        if !hide {
            let keyboardHeight = animationData.endFrame.height
            
            newVisibleRect.size.height -= keyboardHeight
            
            if !newVisibleRect.contains(mostBottomView.frame) {
                let topLeftCorner = mostBottomView.frame.origin.y
                let viewHeight = mostBottomView.frame.size.height + 8
                
                scrollView.setContentOffset(
                    .init(x: 0, y: topLeftCorner + viewHeight - keyboardHeight),
                    animated: true
                )
            }
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
}
