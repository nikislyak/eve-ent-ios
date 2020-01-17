//
//  Collection+Extensions.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 18.01.2020.
//

import Foundation

extension Collection {
    public func sorted<T: Comparable>(by kp: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        sorted(by: { ascending ? $0[keyPath: kp] < $1[keyPath: kp] : $0[keyPath: kp] > $1[keyPath: kp] })
    }
}
