//
//  Publisher+Extensions.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 19.01.2020.
//

import Foundation
import Combine
import XCTest

extension Publisher {
    func sink(exp: XCTestExpectation, _ fulfill: @escaping (Output) -> Void) -> AnyCancellable {
        sink(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                    
                    exp.fulfill()
                default:
                    break
                }
            },
            receiveValue: { output in
                fulfill(output)
            }
        )
    }
    
    func sinkCompletion(exp: XCTestExpectation) -> AnyCancellable {
        sink(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                default:
                    break
                }
                
                exp.fulfill()
            },
            receiveValue: { _ in }
        )
    }
}
