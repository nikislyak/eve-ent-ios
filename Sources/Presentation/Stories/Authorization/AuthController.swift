//
//  AuthController.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.01.2020.
//

import Foundation
import UIKit
import Combine

class AuthController: BaseController<AuthView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typedView.loginBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signIn)))
    }
    
    @objc func signIn() {
        Just(useCasesFactory.makeAuthorizationUseCase())
            .tryFlatMapLatest { [weak typedView] (auth: AuthorizationUseCase) in
                auth.perform(
                    credentials: Credentials(
                        email: try Email(rawValue: typedView?.blockView.emailTextField.text ?? ""),
                        password: try Password(rawValue: typedView?.blockView.passwordTextField.text ?? "")
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
