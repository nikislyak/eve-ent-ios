//
//  BaseScreenFactory.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.12.2019.
//

import Foundation

class BaseScreenFactory {
    let useCasesFactory: UseCasesFactory
    
    init(_ useCasesFactory: UseCasesFactory) {
        self.useCasesFactory = useCasesFactory
    }
}
