import SwiftUI

enum 固定値 {
    static var 盤面枠線の太さ: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: 1.0
            case .pad:
#if targetEnvironment(macCatalyst)
                2.5
#else
                1.33
#endif
            default: 1.0
        }
    }
    static var 強調枠線の太さ: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: 2.0
            case .pad:
#if targetEnvironment(macCatalyst)
                3
#else
                2.5
#endif
            default: 1.0
        }
    }
    static var 全体パディング: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: 16
            case .pad: 24
            default: 16
        }
    }
    static var SharePlayインジケーター上部パディング: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: 12
            case .pad: 16
            default: 16
        }
    }
}
