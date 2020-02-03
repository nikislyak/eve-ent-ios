//
//  AuthValidatorImpl.swift
//  Validation
//
//  Created by Nikita Kislyakov on 01.02.2020.
//

import Foundation
import Domain
import Presentation

public class AuthValidatorImpl: AuthValidator {
    public func validate(credentials: Credentials) -> AuthInputViolations? {
        let email = validate(email: credentials.email)
        let password = validate(password: credentials.password)
        
        if email != nil || password != nil {
            return .init(email: email, password: password)
        }
        
        return nil
    }
    
    private func validate(email: String) -> AuthInputViolations.Email? {
        EmailValidator().validate(email: email)
    }
    
    private func validate(password: String) -> AuthInputViolations.Password? {
        PasswordValidator().validate(password: password)
    }
}

struct EmailValidator {
    func validate(email: String) -> AuthInputViolations.Email? {
        var hasViolations = false
        
        var violatedRules: [EmailValidationRule] = []
        
        if email.range(of: "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}", options: .regularExpression) == nil {
            violatedRules.append(.format)
            
            hasViolations = true
        }
        
        return hasViolations ? .init(rules: violatedRules) : nil
    }
}

struct PasswordValidator {
    static let requiredLengthRange = 8 ..< 32
    
    func validate(password: String) -> AuthInputViolations.Password? {
        var hasViolations = false
        
        var violatedRules: [PasswordValidationRule] = []
        
        if !(PasswordValidator.requiredLengthRange ~= password.count)  {
            violatedRules.append(.length(entered: password.count, mustBe: PasswordValidator.requiredLengthRange))
            
            hasViolations = true
        }
        
        return hasViolations ? .init(rules: violatedRules) : nil
    }
}
