//
//  LayoutGuides.swift
//  Eve-Ent
//
//  Created by Metalluxx on 12.01.2020.
//

import UIKit
import Combine
import Library

final public class KeyboardLayoutGuide: UILayoutGuide {
    weak public var view: UIView!
    
    public private(set) lazy var keyboardPublisher = Publishers.Merge(
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
    )
   
    private var bottomConstraint: NSLayoutConstraint!
    private let usingSafeArea: Bool
    private var bag = Set<AnyCancellable>()
    
    public init(view: UIView, usingSafeArea: Bool = false) {
        self.usingSafeArea = usingSafeArea
        self.view = view
        super.init()
        view.addLayoutGuide(self)
        self.bottomConstraint = self.bottomAnchor.constraint(equalTo: usingSafeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: usingSafeArea ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor),
            self.leftAnchor.constraint(equalTo: usingSafeArea ? view.safeAreaLayoutGuide.leftAnchor : view.leftAnchor),
            self.rightAnchor.constraint(equalTo: usingSafeArea ? view.safeAreaLayoutGuide.rightAnchor : view.rightAnchor),
            bottomConstraint
        ])

        keyboardPublisher
            .sink(
                receiveValue: unowned(self, KeyboardLayoutGuide.receive)
            ).store(in: &bag)
    }

    @objc private func receive(notification: Notification) {
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.bottomConstraint.constant =
                 notification.name == UIView.keyboardWillHideNotification
                 ? 0
                 : -keyboardSize.height + self.view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final public class MarginLayoutGuide: UILayoutGuide {
    public init(for view: UIView, insets: UIEdgeInsets) {
        super.init()
        view.addLayoutGuide(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: insets.right),
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
