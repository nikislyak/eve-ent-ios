//
//  User.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Tagged

struct User: Codable {
    typealias ID = Tagged<User, Int>
    
    let id: ID
    
    var firstName: String
    var lastName: String
    var avatarUrl: URL?
}

extension User {
    static var hole = User(
        id: .zero,
        firstName: "No data",
        lastName: "No data",
        avatarUrl: URL(string: "https://24smi.org/public/media/resize/800x-/celebrity/2017/06/29/WiR3chxn7Xru_ivan-urgant.jpg")
    )
}
