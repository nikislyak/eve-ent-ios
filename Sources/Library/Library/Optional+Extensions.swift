//
//  Optional+Extensions.swift
//  Library
//
//  Created by Nikita Kislyakov on 04.02.2020.
//

import Foundation

extension Optional {
    public func or(_ value: @autoclosure () throws -> Wrapped) rethrows -> Wrapped {
        try (self ?? (try value()))
    }
}
