//
//  User.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

public struct User: Codable {
    public let id: UInt64
    
    public var firstName: String
    public var lastName: String
    public var avatarUrl: URL?
    
    public init(id: UInt64, firstName: String, lastName: String, avatarUrl: URL?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.avatarUrl = avatarUrl
    }
}

extension User {
    static var hole = User(
        id: .zero,
        firstName: "No data",
        lastName: "No data",
        avatarUrl: URL(string: "https://24smi.org/public/media/resize/800x-/celebrity/2017/06/29/WiR3chxn7Xru_ivan-urgant.jpg")
    )
}
