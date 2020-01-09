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
    let router: RouterAbstraction
    
    init(_ useCasesFactory: UseCasesFactory, _ router: RouterAbstraction) {
        self.useCasesFactory = useCasesFactory
        self.router = router
        
        didInit().forEach { $0.store(in: &self.bag) }
    }
    
    func didInit() -> [AnyCancellable] {
        []
    }
}
