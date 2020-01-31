//
//  AuthValidator.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 01.02.2020.
//

import Foundation
import Domain

public enum EmailValidationRule {
    case format
    
    var description: String {
        switch self {
        case .format:
            return L10n.Validation.Auth.Email.formatViolation
        }
    }
}

public enum PasswordValidationRule {
    case length(entered: Int, mustBe: Range<Int>)
    
    var description: String {
        switch self {
        case .length(entered: let entered, mustBe: let requiredLength):
            return L10n.Validation.Auth.Password.requiredLengthViolation(
                "\(requiredLength.lowerBound)",
                "\(requiredLength.upperBound)",
                "\(entered)"
            )
        }
    }
}

public enum AuthInputViolation {
    case email([EmailValidationRule])
    case password([PasswordValidationRule])
    
    var emailRules: [EmailValidationRule] {
        guard case let .email(rules) = self else {
            return []
        }
        
        return rules
    }
    
    var passwordRules: [PasswordValidationRule] {
        guard case let .password(rules) = self else {
            return []
        }
        
        return rules
    }
}

public enum AuthValidatorResult {
    case valid
    case invalid([AuthInputViolation])
    
    var violations: [AuthInputViolation] {
        guard case let .invalid(violations) = self else {
            return []
        }
        
        return violations
    }
}

public protocol AuthValidator {
    func validate(credentials: Credentials) -> AuthValidatorResult
}
