import Foundation

prefix operator ^

prefix func ^ <T, V>(_ kp: KeyPath<T, V>) -> (T) -> V {
    return { $0[keyPath: kp] }
}

prefix func ^ <T, A>(_ o: T) -> (A) -> T {
    return { _ in o }
}

prefix func ^ <T: AnyObject, A>(_ o: T) -> (A) -> T {
    return { [unowned o] _ in o }
}

precedencegroup ForwardApplication {
    associativity: left
    higherThan: ForwardComposition
}

infix operator |> : ForwardApplication

func |> <A, B>(
    _ o: A,
    g: @escaping (A) -> B
) -> B {
    return g(o)
}

precedencegroup KeyPathSetting {
    higherThan: ForwardApplication
}

infix operator .~ : KeyPathSetting

func .~ <T: AnyObject, V>(_ lhs: ReferenceWritableKeyPath<T, V>, _ value: V) -> (T) -> T {
    return { $0[keyPath: lhs] = value; return $0 }
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator >>>: ForwardComposition

func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}
