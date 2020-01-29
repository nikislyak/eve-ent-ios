//
//  NetworkTests.swift
//  Eve-Ent-Tests
//
//  Created by Nikita Kislyakov on 28.01.2020.
//

import XCTest
import Combine
import Foundation
@testable import Library

class MockURLSession: URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<DataTaskResult, Error> {
        Just((data: try! JSONEncoder().encode(1), response: URLResponse()))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class NetworkTests: XCTestCase {
    let url = URL(string: "https://github.com/")!
    
    var mockSession: MockURLSession!
    var network: Network!

    override func setUp() {
        super.setUp()
        
        mockSession = MockURLSession()
        
        network = .init(
            env: .init(
                urlSession: mockSession,
                baseUrl: url,
                decoder: .init(),
                encoder: .init()
            )
        )
    }

    override func tearDown() {
        mockSession = nil
        network = nil
        
        super.tearDown()
    }

    func testPerform() {
        waiting { exp in
            network
                .perform(request: URLRequest(url: url))
                .sink(exp: exp) { (data: Int) in
                    XCTAssertEqual(data, 1)
                    
                    exp.fulfill()
                }
        }
    }
    
    func testRequestThenPerform() throws {
        waiting { exp in
            network
                .request(path: "")
                .body(data: Data())
                .perform()
                .sink(exp: exp) { (value: Int) in
                    XCTAssertEqual(value, 1)
                    
                    exp.fulfill()
                }
        }
    }
    
    func testRequestMethod() throws {
        var expectedRequest = URLRequest(url: url)
        
        expectedRequest.httpMethod = "GET"
        
        var builder = network.request(path: "")
        
        builder = builder.method(.GET)
        
        XCTAssertEqual(expectedRequest, builder.builder.build())
        
        expectedRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        builder = builder.header(key: "Content-Type", value: "application/json")
        
        XCTAssertEqual(expectedRequest, builder.builder.build())
        
        expectedRequest.allowsCellularAccess = true
        
        builder = builder.set(\.allowsCellularAccess, true)
        
        XCTAssertEqual(expectedRequest, builder.builder.build())
        
        expectedRequest.httpBody = try JSONEncoder().encode(1)
        
        builder = builder.body(data: try JSONEncoder().encode(1))
        
        XCTAssertEqual(expectedRequest, builder.builder.build())
        
        let headers = [
            "a": "a",
            "b": "b"
        ]
        
        headers.forEach { expectedRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        builder = builder.headers(headers)
        
        XCTAssertEqual(expectedRequest, builder.builder.build())
    }
}
