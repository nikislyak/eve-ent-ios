//
//  ValidatorsFactory.swift
//  Presentation
//
//  Created by Nikita Kislyakov on 01.02.2020.
//

import Foundation

public protocol ValidatorsFactory {
    func makeAuthValidator() -> AuthValidator
}
