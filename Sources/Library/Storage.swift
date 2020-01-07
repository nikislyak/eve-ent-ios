import Foundation

protocol ReadableStorage {
    func getObject<T: Decodable>(forKey key: String) -> T?
}

protocol WritableStorage {
    func save<T: Encodable>(object: T, forKey key: String)
    func removeObject(byKey key: String)
}

typealias Storage = ReadableStorage & WritableStorage
