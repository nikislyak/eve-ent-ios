//
//  BaseViewModel.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 12.12.2019.
//

import Foundation
import Combine

class BaseViewModel {
    var bag = Set<AnyCancellable>()
    
    let useCasesFactory: UseCasesFactory
    
    init(_ useCasesFactory: UseCasesFactory) {
        self.useCasesFactory = useCasesFactory
        
        didInit().forEach { $0.store(in: &self.bag) }
    }
    
    func didInit() -> [AnyCancellable] {
        []
    }
}
