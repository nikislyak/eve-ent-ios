//
//  Credentials.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

public struct Email {
    public var value: String
    
    public init(rawValue: String) throws {
//        guard rawValue.contains("@") else { throw IdentifiableError(id: 0) }
        
        value = rawValue
    }
}

public struct Password {
    public var value: String
    
    public init(rawValue: String) throws {
//        guard 8 ... 32 ~= rawValue.count else { throw IdentifiableError(id: 1) }
        
        value = rawValue
    }
}

public struct Credentials {
    public var email: Email
    public var password: Password
    
    public init(email: Email, password: Password) {
        self.email = email
        self.password = password
    }
}
