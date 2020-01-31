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
    public func validate(credentials: Credentials) -> AuthValidatorResult {
        let results = validate(email: credentials.email) + validate(password: credentials.password)
        
        return results.isEmpty ? .valid : .invalid(results)
    }
    
    private func validate(email: String) -> [AuthInputViolation] {
        EmailValidator().validate(email: email)
    }
    
    private func validate(password: String) -> [AuthInputViolation] {
        PasswordValidator().validate(password: password)
    }
}

struct EmailValidator {
    func validate(email: String) -> [AuthInputViolation] {
        var hasViolations = false
        
        var violatedRules: [EmailValidationRule] = []
        
        if !email.contains("@") {
            violatedRules.append(.format)
            
            hasViolations = true
        }
        
        return hasViolations ? [.email(violatedRules)] : []
    }
}

struct PasswordValidator {
    static let requiredLengthRange = 8 ..< 32
    
    func validate(password: String) -> [AuthInputViolation] {
        var hasViolations = false
        
        var violatedRules: [PasswordValidationRule] = []
        
        if !(PasswordValidator.requiredLengthRange ~= password.count)  {
            violatedRules.append(.length(entered: password.count, mustBe: PasswordValidator.requiredLengthRange))
            
            hasViolations = true
        }
        
        return hasViolations ? [.password(violatedRules)] : []
    }
}
