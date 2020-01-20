//
//  KeyboardListener.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 14.12.2019.
//

import Foundation
import Combine
import SwiftUI

class KeyboardListener: ObservableObject {
    @Published var keyboardTargetHeight: CGFloat = 0
    
    private var bag = Set<AnyCancellable>()
    
    init() {
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
            .store(in: &bag)
    }
    
    private func handle(showHide: Notification, changeFrame: Notification) {
        let hide = showHide.name == UIResponder.keyboardWillHideNotification
        
        animate(hide: hide, with: extractAnimationData(from: changeFrame))
    }
    
    private struct AnimationData {
        let duration: Double
        let options: UIView.AnimationOptions
        let beginFrame: CGRect
        let endFrame: CGRect
        
        var animation: Animation {
            let animation: Animation
            
            if options.contains(.curveEaseIn) {
                animation = .easeIn(duration: duration)
            } else if options.contains(.curveEaseInOut) {
                animation = .easeOut(duration: duration)
            } else if options.contains(.curveEaseOut) {
                animation = .easeOut(duration: duration)
            } else if options.contains(.curveLinear) {
                animation = .linear(duration: duration)
            } else {
                animation = .default
            }
            
            return animation
        }
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
    
    private func animate(hide: Bool, with animationData: AnimationData) {
        withAnimation(animationData.animation) {
            keyboardTargetHeight = hide ? 0 : animationData.endFrame.height
        }
    }
}
