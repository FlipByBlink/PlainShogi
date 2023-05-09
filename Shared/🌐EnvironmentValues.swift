import SwiftUI

extension EnvironmentValues {
    var マスの大きさ: CGFloat {
        get { self[マスの大きさKey.self] }
        set { self[マスの大きさKey.self] = newValue }
    }
    
#if os(iOS)
    var 縦並び: Bool {
        get { self[縦並びKey.self] }
        set { self[縦並びKey.self] = newValue }
    }
#endif
}

private struct マスの大きさKey: EnvironmentKey { static let defaultValue = 30.0 }

#if os(iOS)
private struct 縦並びKey: EnvironmentKey { static let defaultValue = false }
#endif
