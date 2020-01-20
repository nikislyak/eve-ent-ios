//
//  PredicatePlaceholderProvider.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 16.01.2020.
//

import Foundation

public protocol PredicatePlaceholderProvider {
    static var placeholder: String { get }
}

extension Int: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}

extension Int8: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}

extension Int16: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}

extension Int32: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}

extension Int64: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}

extension UInt: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}

extension UInt8: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}

extension UInt16: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}

extension UInt32: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}

extension UInt64: PredicatePlaceholderProvider {
    public static var placeholder: String {
        "%d"
    }
}
