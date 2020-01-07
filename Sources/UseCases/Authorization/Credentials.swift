//
//  Credentials.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

struct Email {
    let value: String
    
    init(rawValue: String) throws {
        guard rawValue.contains("@") else { throw IdentifiableError(id: 0) }
        
        value = rawValue
    }
}

struct Password {
    let value: String
    
    init(rawValue: String) throws {
        guard 8 ... 32 ~= rawValue.count else { throw IdentifiableError(id: 1) }
        
        value = rawValue
    }
}

struct Credentials {
    let email: Email
    let password: Password
}
