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

public struct AuthInputViolations {
    public struct Email {
        public var rules: [EmailValidationRule]
        
        public init(rules: [EmailValidationRule]) {
            self.rules = rules
        }
    }
    
    public struct Password {
        public var rules: [PasswordValidationRule]
        
        public init(rules: [PasswordValidationRule]) {
            self.rules = rules
        }
    }
    
    public var email: Email?
    public var password: Password?
    
    public init(email: Email?, password: Password?) {
        self.email = email
        self.password = password
    }
}

public protocol AuthValidator {
    func validate(credentials: Credentials) -> AuthInputViolations?
}
