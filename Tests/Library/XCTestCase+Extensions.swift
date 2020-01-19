//
//  XCTestCase+Extensions.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import XCTest
import Combine

extension XCTestCase {
    func waiting<T: Cancellable>(_ message: String? = nil, timeout: TimeInterval = 1, _ exec: (XCTestExpectation) -> T) -> Void {
        let exp = message == nil ? expectation(description: "") : expectation(description: message!)
        
        let something = exec(exp)
        
        waitForExpectations(timeout: timeout) {
            $0.map { _ in
                something.cancel()
            }
        }
    }
}
