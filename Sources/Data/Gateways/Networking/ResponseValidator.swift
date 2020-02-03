//
//  ResponseValidator.swift
//  Data
//
//  Created by Nikita Kislyakov on 30.01.2020.
//

import Foundation
import Combine
import Networking

public class ResponseValidator: NetworkResponseValidator {
    public init() {}
    
    public func isValid(response: URLResponse) -> Bool {
        (response as? HTTPURLResponse).map {
            !(400 ..< 500 ~= $0.statusCode)
        } ?? true
    }
}
