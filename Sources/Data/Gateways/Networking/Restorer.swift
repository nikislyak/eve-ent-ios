//
//  Restorer.swift
//  Data
//
//  Created by Nikita Kislyakov on 30.01.2020.
//

import Foundation
import Networking
import Combine
import Library

public class Restorer: RequestRestorer {
    private let tokensStorage: Storage
    private let network: Network
    
    public init(tokensStorage: Storage, network: Network) {
        self.tokensStorage = tokensStorage
        self.network = network
    }
    
    public func restore() -> AnyPublisher<Void, Error> {
        Just(())
            .tryMap { [network] _ -> AnyPublisher<String, Error> in
                network
                    .request(path: "auth/refresh", encoding: JSONEncoding())
                    .method(.POST)
                    .body(data: try JSONEncoder().encode(""))
                    .perform()
        }
        .flatMap { $0 }
        .map { [tokensStorage] in
            tokensStorage.save(object: $0, forKey: "tokens")
        }
        .eraseToAnyPublisher()
    }
}
