import Foundation

public protocol ReadableStorage {
    func getObject<T: Decodable>(forKey key: String) -> T?
}

public protocol WritableStorage {
    func save<T: Encodable>(object: T, forKey key: String)
    func removeObject(byKey key: String)
}

public typealias Storage = ReadableStorage & WritableStorage
