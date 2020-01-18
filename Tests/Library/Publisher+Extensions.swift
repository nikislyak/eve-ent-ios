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
    func sink(_ fulfill: @escaping (Output) -> Void) -> AnyCancellable {
        sink(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    XCTFail(error.localizedDescription)
                default:
                    break
                }
            },
            receiveValue: { output in
                fulfill(output)
            }
        )
    }
}
