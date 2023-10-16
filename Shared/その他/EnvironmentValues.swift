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


#if os(iOS)
extension EnvironmentValues {
    var 縦並び: Bool {
        get { self[Self.縦並びKey.self] }
        set { self[Self.縦並びKey.self] = newValue }
    }
    private struct 縦並びKey: EnvironmentKey {
        static let defaultValue = false
    }
}
#endif
