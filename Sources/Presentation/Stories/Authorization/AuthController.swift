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

public class AuthController: BaseController<AuthView>, KeyboardManagable {
    override class var keyboardManagerClass: KeyboardManager.Type {
        SafeAreaAdjustingKeyboardManager.self
    }
    
    public var managedScrollView: UIScrollView {
        typedView.scrollView
    }
    
    public var mostBottomView: UIView? {
        return typedView.activeTextInput
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        typedView.loginBtn.view.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    }
    
    override func setup() {
        super.setup()
        
        keyboardManager.viewController = self
    }
    
    @objc func signIn() {
        let creds = Credentials(
            email: typedView?.blockView.view.emailTextField.text ?? "",
            password: typedView?.blockView.view.passwordTextField.text ?? ""
        )
        
        Just(creds)
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .tryMap { [validatorsFactory] creds -> Credentials in
                let violations = validatorsFactory
                    .makeAuthValidator()
                    .validate(credentials: creds)
                
                if let violations = violations {
                    throw AuthValidationError(violations: violations)
                }
                
                return creds
            }
            .flatMap(useCasesFactory.makeAuthorizationUseCase().perform)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self.map { strongSelf in
                        completion
                            .error
                            .flatMap(cast(to: AuthValidationError.self))
                            .map(strongSelf.handle)
                    }
                },
                receiveValue: {}
            )
            .store(in: &bag)
    }
    
    private func handle(validationError: AuthValidationError) {
        alert(style: .alert)
            .action(title: "OK", style: .default)
            .set(\.title, "Incorrect input")
            .set(\.message, validationError.localizedDescription)
            .show() as Void
    }
}

struct AuthValidationError: Error {
    var violations: AuthInputViolations
    
    var localizedDescription: String {
        let emailRules = violations.email?.rules.map { $0.description }.joined(separator: "\n")
        let passwordRules = violations.password?.rules.map { $0.description }.joined(separator: "\n")
        
        return [emailRules, passwordRules].compactMap(it).joined(separator: "\n")
    }
}
