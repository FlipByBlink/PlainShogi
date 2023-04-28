import Foundation

enum 💾ICloud {
    private static var api: NSUbiquitousKeyValueStore { .default }
    static func addObserver(_ ⓞbserver: Any, _ ⓢelector: Selector) {
        NotificationCenter.default.addObserver(ⓞbserver,
                                               selector: ⓢelector,
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default)
    }
}

extension 💾ICloud {
    static func synchronize() { self.api.synchronize() }
    static func set(_ データ: Data, key ⓚey: String) { Self.api.set(データ, forKey: ⓚey) }
    static func data(key ⓚey: String) -> Data? { Self.api.data(forKey: ⓚey) }
    static func remove(key ⓚey: String) { Self.api.removeObject(forKey: ⓚey) }
}

//enum 💾UserDefaults {
//    private static var api: UserDefaults { .standard }
//    static func set(_ データ: Data, key ⓚey: String) { Self.api.set(データ, forKey: ⓚey) }
//    static func data(key ⓚey: String) -> Data? { Self.api.data(forKey: ⓚey) }
//    static func remove(key ⓚey: String) { Self.api.removeObject(forKey: ⓚey) }
//}
