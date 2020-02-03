//
//  AlertBuilder.swift
//  Library
//
//  Created by Nikita Kislyakov on 03.02.2020.
//

import Foundation
import UIKit
import Overture
import Combine

public struct AlertBuilder {
    private let controller: UIAlertController
    
    public init(style: UIAlertController.Style) {
        controller = UIAlertController(title: nil, message: nil, preferredStyle: style)
    }
    
    private init(controller: UIAlertController) {
        self.controller = controller
    }
    
    public func action(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        controller.addAction(.init(title: title, style: style, handler: handler))
        
        return .init(controller: controller)
    }
    
    public func textField(configurationHandler: ((UITextField) -> Void)? = nil) -> Self {
        controller.addTextField(configurationHandler: configurationHandler)
        
        return .init(controller: controller)
    }
    
    public func set<V>(_ keyPath: ReferenceWritableKeyPath<UIAlertController, V>, _ value: V) -> Self {
        controller[keyPath: keyPath] = value
        
        return .init(controller: controller)
    }
    
    public func build() -> UIAlertController {
        controller
    }
}

public struct IncompleteAlert {
    private let controller: UIViewController
    private let builder: AlertBuilder
    
    fileprivate init(controller: UIViewController, style: UIAlertController.Style) {
        self = .init(controller: controller, builder: .init(style: style))
    }
    
    private init(controller: UIViewController, builder: AlertBuilder) {
        self.controller = controller
        self.builder = builder
    }
    
    public func action(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) -> Self {
        .init(controller: controller, builder: builder.action(title: title, style: style, handler: handler))
    }
    
    public func textField(configurationHandler: ((UITextField) -> Void)? = nil) -> Self {
        .init(controller: controller, builder: builder.textField(configurationHandler: configurationHandler))
    }
    
    public func set<V>(_ keyPath: ReferenceWritableKeyPath<UIAlertController, V>, _ value: V) -> Self {
        .init(controller: controller, builder: builder.set(keyPath, value))
    }
    
    public func show() {
        controller.show(builder.build(), sender: self)
    }
    
    public func present(animated: Bool = true, completion: (() -> Void)?) {
        controller.present(builder.build(), animated: animated, completion: completion)
    }
}

extension IncompleteAlert {
    public func show() -> AnyPublisher<Void, Never> {
        Just(show()).eraseToAnyPublisher()
    }
    
    public func present(animated: Bool = true) -> AnyPublisher<Void, Never> {
        Deferred {
            Future { promise in
                self.present(animated: animated) {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension UIViewController {
    public func alert(style: UIAlertController.Style) -> IncompleteAlert {
        .init(controller: self, style: style)
    }
    
    public static func makeAlert(
        style: UIAlertController.Style,
        configure: @escaping (IncompleteAlert) -> IncompleteAlert
    ) -> (UIViewController) -> IncompleteAlert {
        return { controller in
            configure(flip(curry(IncompleteAlert.init))(style)(controller))
        }
    }
}
