//
//  Tokens.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

struct Tokens: Codable {
    var accessToken: String
    var refreshToken: String
    
    var user: User
}
