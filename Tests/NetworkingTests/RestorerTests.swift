//
//  RestorerTests.swift
//  Eve-Ent-Tests
//
//  Created by Nikita Kislyakov on 01.02.2020.
//

import Foundation
import Data
import Combine
import Domain
import Library
import XCTest

class MockStorage: Storage {
    var value: Any?

    func getObject<T>(forKey key: String) -> T? where T : Decodable {
        value as? T
    }
    
    func save<T>(object: T, forKey key: String) where T : Encodable {
        value = object
    }
    
    func removeObject(byKey key: String) {
        value = nil
    }
}

class MockRefreshTokensGateway: RefreshTokensGateway {
    var tokens: Tokens!
    
    func newTokens(refreshToken: String) -> AnyPublisher<Tokens, Error> {
        Result.Publisher(tokens).eraseToAnyPublisher()
    }
}

class RestorerTests: XCTestCase {
    var gateway: MockRefreshTokensGateway!
    var tokensStorage: MockStorage!
    var restorer: Restorer!
    
    override func setUp() {
        super.setUp()
        
        gateway = MockRefreshTokensGateway()
        tokensStorage = MockStorage()
        
        restorer = Restorer(
            tokensStorage: tokensStorage,
            refreshTokensGateway: gateway
        )
    }
    
    override func tearDown() {
        restorer = nil
        
        super.tearDown()
    }
    
    func testFailsWhenNoTokensInStorage() {
        waiting { exp in
            restorer
                .restore()
                .sink(
                    receiveCompletion: { compl in
                        let restorerError = compl
                            .error
                            .flatMap(cast(to: Restorer.Error.self))
                        
                        XCTAssertNotNil(restorerError)
                        
                        exp.fulfill()
                    },
                    receiveValue: {}
                )
        }
    }
    
    func testSavesNewTokensInStorage() {
        let oldTokens = Tokens(accessToken: "old-access-token", refreshToken: "old-refresh-token")
        let newTokens = Tokens(accessToken: "new-access-token", refreshToken: "new-refresh-token")
        
        tokensStorage.save(object: oldTokens, forKey: "tokens")
        gateway.tokens = newTokens
        
        waiting { exp in
            restorer
                .restore()
                .sink(exp: exp) {
                    let savedTokens = self.tokensStorage.value as? Tokens
                    
                    XCTAssertNotNil(savedTokens)
                    XCTAssertEqual(savedTokens, newTokens)
                    
                    exp.fulfill()
                }
        }
    }
}
