//
//  Tokens.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

public struct Tokens: Codable {
    public var accessToken: String
    public var refreshToken: String
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
