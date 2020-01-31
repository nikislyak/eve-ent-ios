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
            .receive(on: DispatchQueue.global())
            .tryMap { [validatorsFactory] creds -> Credentials in
                let violations = validatorsFactory
                    .makeAuthValidator()
                    .validate(credentials: creds)
                    .violations
                
                if !violations.isEmpty {
                    throw AuthValidationError(violations: violations)
                }
                
                return creds
            }
            .map { [useCasesFactory] creds in
                useCasesFactory.makeAuthorizationUseCase().perform(credentials: creds)
            }
            .flatMap(it)
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
        let alertController = UIAlertController(
            title: "Incorrect input",
            message: validationError.localizedDescription,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        show(alertController, sender: self)
    }
}

struct AuthValidationError: Error {
    var violations: [AuthInputViolation]
    
    var localizedDescription: String {
        let emailRules = violations.reduce([]) {
            $0 + $1.emailRules
        }
        
        let passwordRules = violations.reduce([]) {
            $0 + $1.passwordRules
        }
        
        let emailDescriptions = emailRules.map { $0.description }.joined(separator: "\n")
        let passwordDescriptions = passwordRules.map { $0.description }.joined(separator: "\n")
        
        return [emailDescriptions, passwordDescriptions].joined(separator: "\n")
    }
}
