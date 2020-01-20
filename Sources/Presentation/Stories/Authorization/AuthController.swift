//
//  AuthController.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.01.2020.
//

import Foundation
import UIKit
import Combine
import Library
import Domain

class AuthController: BaseController<AuthView>, KeyboardManagable {
    override class var keyboardManagerClass: KeyboardManager.Type {
        SafeAreaAdjustingKeyboardManager.self
    }
    
    var managedScrollView: UIScrollView {
        typedView.scrollView
    }
    
    var mostBottomView: UIView? {
        return typedView.activeTextInput
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typedView.loginBtn.view.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    }
    
    override func setup() {
        super.setup()
        
        keyboardManager.viewController = self
    }
    
    @objc func signIn() {
        Just(useCasesFactory.makeAuthorizationUseCase())
            .tryFlatMapLatest { [weak typedView] (auth: AuthorizationUseCase) in
                auth.perform(
                    credentials: Credentials(
                        email: try Email(rawValue: typedView?.blockView.view.emailTextField.text ?? ""),
                        password: try Password(rawValue: typedView?.blockView.view.passwordTextField.text ?? "")
                    )
                )
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] in $0.error.map { _ in self?.state.email = "ERROR" } },
                receiveValue: { [weak self] in self?.state.email = "SUCCESS" }
            )
            .store(in: &bag)
    }
}
