//
//  ErrorTypes.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 21.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

struct IdentifiableError: Error, Identifiable, Equatable {
    var id: Int
}
