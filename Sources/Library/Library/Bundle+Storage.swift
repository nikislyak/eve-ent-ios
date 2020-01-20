import Foundation

public class ApplicationInfo: ReadableStorage {
    private let bundle: Bundle
    
    public init(bundle: Bundle) {
        self.bundle = bundle
    }
    
    public func getObject<T: Decodable>(forKey key: String) -> T? {
        bundle.object(forInfoDictionaryKey: key) as? T
    }
}
