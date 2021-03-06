//
//  UserDefaults+Storage.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 25.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation

public class UserDefaultsStorage: Storage {
    private let userDefaults: UserDefaults
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(userDefaults: UserDefaults, decoder: JSONDecoder, encoder: JSONEncoder) {
        self.userDefaults = userDefaults
        self.decoder = decoder
        self.encoder = encoder
    }
    
    public func getObject<T>(forKey key: String) -> T? where T : Decodable {
        guard let data = userDefaults.data(forKey: key),
            let object = try? decoder.decode(T.self, from: data)
        else {
            return nil
        }
        
        return object
    }
    
    public func save<T>(object: T, forKey key: String) where T : Encodable {
        guard let data = try? encoder.encode(object) else { return }
        
        userDefaults.set(data, forKey: key)
    }
    
    public func removeObject(byKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
