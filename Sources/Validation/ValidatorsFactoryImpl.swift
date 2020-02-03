//
//  ValidatorsFactoryImpl.swift
//  Validation
//
//  Created by Nikita Kislyakov on 01.02.2020.
//

import Foundation
import Presentation

public class ValidatorsFactoryImpl: ValidatorsFactory {
    private lazy var authValidator = AuthValidatorImpl()
    
    public init() {}
    
    public func makeAuthValidator() -> AuthValidator {
        authValidator
    }
}
