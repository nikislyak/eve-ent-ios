//
//  AuthorizationUseCaseTests.swift
//  Eve-Ent-Tests
//
//  Created by Nikita Kislyakov on 04.02.2020.
//

import Foundation
import Domain
import Library
import XCTest
import Combine

class MockAuthorizationGateway: AuthorizationGateway {
    var tokens: Tokens!
    
    func authorize(credentials: Credentials) -> AnyPublisher<Tokens, Error> {
        Result.Publisher(tokens).eraseToAnyPublisher()
    }
}

class MockTokensStorageGateway: TokensStorageGateway {
    var tokens: Tokens?
    
    func get() -> AnyPublisher<Tokens?, Error> {
        Result.Publisher(tokens).eraseToAnyPublisher()
    }
    
    func save(_ tokens: Tokens) -> AnyPublisher<Void, Error> {
        Result {
            self.tokens = tokens
        }
        .publisher
        .eraseToAnyPublisher()
    }
    
    func remove() -> AnyPublisher<Void, Error> {
        Result {
            self.tokens = nil
        }
        .publisher
        .eraseToAnyPublisher()
    }
}

class AuthorizationUseCaseTests: XCTestCase {
    var tokensStorageGateway: MockTokensStorageGateway!
    var authGateway: MockAuthorizationGateway!
    var auth: AuthorizationUseCase!
    
    override func setUp() {
        super.setUp()
        
        authGateway = MockAuthorizationGateway()
        tokensStorageGateway = MockTokensStorageGateway()
        
        auth = AuthorizationUseCase(authGateway, tokensStorageGateway)
    }
    
    override func tearDown() {
        super.tearDown()
        
        authGateway = nil
        tokensStorageGateway = nil
        auth = nil
    }
    
    func testSavesTokensToTokensStorage() {
        let creds = Credentials(email: "email", password: "password")
        
        authGateway.tokens = Tokens(accessToken: "access-token", refreshToken: "refresh-token")
        
        waiting { exp in
            auth
                .perform(credentials: creds)
                .flatMap(tokensStorageGateway.get)
                .sink(exp: exp) { tokens in
                    XCTAssertNotNil(tokens)
                    XCTAssertEqual(tokens, self.authGateway.tokens)
                    
                    exp.fulfill()
                }
        }
    }
    
    func testRemovesTokensFromTokensStorage() {
        let creds = Credentials(email: "email", password: "password")
        
        authGateway.tokens = Tokens(accessToken: "access-token", refreshToken: "refresh-token")
        
        waiting { exp in
            auth
                .perform(credentials: creds)
                .flatMap(tokensStorageGateway.get)
                .map { tokens in
                    XCTAssertNotNil(tokens)
                    XCTAssertEqual(tokens, self.authGateway.tokens)
                }
                .flatMap(auth.deauth)
                .flatMap(tokensStorageGateway.get)
                .sink(exp: exp) { tokens in
                    XCTAssertNil(tokens)
                    
                    exp.fulfill()
                }
        }
    }
    
    func testDetectsAuthState() {
        let creds = Credentials(email: "email", password: "password")
        
        authGateway.tokens = Tokens(accessToken: "access-token", refreshToken: "refresh-token")
        
        waiting { exp in
            auth
                .perform(credentials: creds)
                .flatMap(auth.state)
                .sink(exp: exp) { state in
                    XCTAssertEqual(state, .authorized)
                    XCTAssertTrue(state.isAuthorized)
                    
                    exp.fulfill()
                }
        }
    }
}
