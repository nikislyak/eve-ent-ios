//
//  UserDefaults+Storage.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 25.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

class UserDefaultsStorage: Storage {
    private let userDefaults: UserDefaults
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(userDefaults: UserDefaults, decoder: JSONDecoder, encoder: JSONEncoder) {
        self.userDefaults = userDefaults
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func getObject<T>(forKey key: String) -> T? where T : Decodable {
        guard let data = userDefaults.data(forKey: key),
            let object = try? decoder.decode(T.self, from: data)
        else {
            return nil
        }
        
        return object
    }
    
    func save<T>(object: T, forKey key: String) where T : Encodable {
        guard let data = try? encoder.encode(object) else { return }
        
        userDefaults.set(data, forKey: key)
    }
    
    func removeObject(byKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
