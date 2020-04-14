//
//  WeakReference.swift
//  Library
//
//  Created by Nikita Kislyakov on 14.04.2020.
//

import Foundation

public final class WeakOwned<T: AnyObject> {
    private var reference = WeakReference<T>()

    public var value: T? {
        reference.value
    }

    public init() {}

    public func get(or create: @autoclosure () -> T) -> T {
        let value: T

        if reference.isEmpty {
            value = create()
            reference.value = value
        } else {
            value = reference.value!
        }

        return value
    }
}

public struct WeakReference<T: AnyObject> {
    public weak var value: T?

    public var isEmpty: Bool {
        value == nil
    }
}
