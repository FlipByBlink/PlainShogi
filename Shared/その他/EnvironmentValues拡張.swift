import SwiftUI

extension EnvironmentValues {
    var マスの大きさ: CGFloat {
        get { self[Self.マスの大きさKey.self] }
        set { self[Self.マスの大きさKey.self] = newValue }
    }
    private struct マスの大きさKey: EnvironmentKey {
        static let defaultValue = 30.0
    }
}

#if os(iOS) || os(visionOS)
extension EnvironmentValues {
    var 縦並び: Bool {
        get { self[Self.縦並びKey.self] }
        set { self[Self.縦並びKey.self] = newValue }
    }
    private struct 縦並びKey: EnvironmentKey {
        static let defaultValue = false
    }
    
    var 画像書き出し: Bool {
        get { self[Self.画像書き出しKey.self] }
        set { self[Self.画像書き出しKey.self] = newValue }
    }
    private struct 画像書き出しKey: EnvironmentKey {
        static let defaultValue = false
    }
}
#endif
