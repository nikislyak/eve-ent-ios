import Foundation

class ApplicationInfo: ReadableStorage {
    private let bundle: Bundle
    
    func getObject<T: Decodable>(forKey key: String) -> T? {
        return bundle.object(forInfoDictionaryKey: key) as? T
    }
    
    init(bundle: Bundle) {
        self.bundle = bundle
    }
}
