//
//  Combine+Ext.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 06.12.2019.
//

import Foundation
import Combine

extension Subscribers.Completion {
    public var error: Failure? {
        guard case let .failure(error) = self else { return nil }
        
        return error
    }
}

extension Collection where Element: Cancellable {
    public func store(in bag: inout Set<AnyCancellable>) {
        forEach { $0.store(in: &bag) }
    }
    
    public func store<C: RangeReplaceableCollection>(in bag: inout C) where C.Element == AnyCancellable {
        forEach { $0.store(in: &bag) }
    }
}
