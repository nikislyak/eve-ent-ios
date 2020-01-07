//
//  Combine+Ext.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 06.12.2019.
//

import Foundation
import Combine

extension Subscribers.Completion {
    var error: Failure? {
        guard case let .failure(error) = self else { return nil }
        
        return error
    }
}
