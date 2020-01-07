//
//  Keychain+Storage.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 25.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import KeychainAccess

class KeychainStorage: Storage {
    private let keychain: Keychain
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(keychain: Keychain, decoder: JSONDecoder, encoder: JSONEncoder) {
        self.keychain = keychain
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func getObject<T>(forKey key: String) -> T? where T : Decodable {
        guard let data = try? keychain.getData(key),
            let object = try? decoder.decode(T.self, from: data)
        else {
            return nil
        }
        
        return object
    }
    
    func save<T>(object: T, forKey key: String) where T : Encodable {
        guard let data = try? encoder.encode(object) else { return }
        
        try? keychain.set(data, key: key)
    }
    
    func removeObject(byKey key: String) {
        try? keychain.remove(key)
    }
}
