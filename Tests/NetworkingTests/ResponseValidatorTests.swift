//
//  ResponseValidatorTests.swift
//  Eve-Ent-Tests
//
//  Created by Nikita Kislyakov on 30.01.2020.
//

import Foundation
import Data
import XCTest

class ResponseValidatorTests: XCTestCase {
    var validator: ResponseValidator!
    
    override func setUp() {
        super.setUp()
        
        validator = ResponseValidator()
    }
    
    override func tearDown() {
        validator = nil
        
        super.tearDown()
    }
    
    func testIsValidReturnsFalse() {
        let response = HTTPURLResponse(url: URL(string: "https://github.com/")!, statusCode: 401, httpVersion: "HTTP/1.1", headerFields: nil)!
        
        XCTAssertFalse(validator!.isValid(response: response))
    }
    
    func testIsValidReturnsTrue() {
        let response = HTTPURLResponse(url: URL(string: "https://github.com/")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        
        XCTAssert(validator!.isValid(response: response))
        
        let notHTTPResponse = URLResponse(url: URL(string: "https://github.com/")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        
        XCTAssertTrue(validator.isValid(response: notHTTPResponse))
    }
}
