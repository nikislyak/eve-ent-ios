//
//  Keychain+Storage.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 25.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import KeychainAccess

public class KeychainStorage: Storage {
    private let keychain: Keychain
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(keychain: Keychain, decoder: JSONDecoder, encoder: JSONEncoder) {
        self.keychain = keychain
        self.decoder = decoder
        self.encoder = encoder
    }
    
    public func getObject<T>(forKey key: String) -> T? where T : Decodable {
        guard let data = try? keychain.getData(key),
            let object = try? decoder.decode(T.self, from: data)
        else {
            return nil
        }
        
        return object
    }
    
    public func save<T>(object: T, forKey key: String) where T : Encodable {
        guard let data = try? encoder.encode(object) else { return }
        
        try? keychain.set(data, key: key)
    }
    
    public func removeObject(byKey key: String) {
        try? keychain.remove(key)
    }
}
