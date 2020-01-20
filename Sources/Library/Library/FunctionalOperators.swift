import Foundation

prefix operator ^

public prefix func ^ <T, V>(_ kp: KeyPath<T, V>) -> (T) -> V {
    return { $0[keyPath: kp] }
}

precedencegroup ForwardApplication {
    associativity: left
    higherThan: ForwardComposition
}

infix operator |> : ForwardApplication

@discardableResult
public func |> <A, B>(_ o: A, g: @escaping (A) -> B) -> B {
    g(o)
}

precedencegroup KeyPathSetting {
    higherThan: ForwardApplication
}

infix operator .~ : KeyPathSetting

public func .~ <T: AnyObject, V>(_ kp: ReferenceWritableKeyPath<T, V>, _ value: V) -> (T) -> T {
    return { $0[keyPath: kp] = value; return $0 }
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator >>> : ForwardComposition

public func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}
