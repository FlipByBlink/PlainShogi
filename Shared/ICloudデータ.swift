import SwiftUI

enum ICloudデータ {
    private static var api: NSUbiquitousKeyValueStore { .default }
}

extension ICloudデータ {
    static func synchronize() {
        self.api.synchronize()
    }
    static func set(_ data: Data, key: String) {
        Self.api.set(data, forKey: key)
    }
    static func data(key: String) -> Data? {
        Self.api.data(forKey: key)
    }
    static func remove(key: String) {
        Self.api.removeObject(forKey: key)
    }
}

extension ICloudデータ {
    static func addObserver(_ observer: Any, _ selector: Selector) {
        NotificationCenter
            .default
            .addObserver(observer,
                         selector: selector,
                         name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                         object: Self.api)
    }
}

extension ICloudデータ {
    static func このキーが変更された(key: NSString, _ notification: Notification) -> Bool {
        guard let keys = notification.userInfo?["NSUbiquitousKeyValueStoreChangedKeysKey"] as? [NSString] else {
            return false
        }
        return keys.contains(key)
    }
}

extension ICloudデータ {
    struct アクティブ復帰時に明示的に同期: ViewModifier {
        @Environment(\.scenePhase) private var scenePhase
        func body(content: Content) -> some View {
            content
                .onChange(of: self.scenePhase) {
                    if $0 == .active { ICloudデータ.synchronize() }
                }
        }
    }
}
