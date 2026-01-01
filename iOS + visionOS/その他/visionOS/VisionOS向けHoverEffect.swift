import SwiftUI

enum VisionOS向けHoverEffect {
    struct コマ: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        @AppStorage("ホバーエフェクト無効") var ホバーエフェクト無効: Bool = false
        func body(content: Content) -> some View {
            content
#if os(visionOS)
                .hoverEffect(isEnabled: {
                    if self.ホバーエフェクト無効 {
                        false
                    } else {
                        if self.モデル.選択中の駒 == .なし {
                            true
                        } else {
                            if self.モデル.駒を持ち上げたのは自分 {
                                true
                            } else {
                                false
                            }
                        }
                    }
                }())
#endif
        }
    }
    struct マス: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        @AppStorage("ホバーエフェクト無効") var ホバーエフェクト無効: Bool = false
        func body(content: Content) -> some View {
            content
#if os(visionOS)
                .border(.gray.opacity(0.001), width: 0.001) //Workaround
                .hoverEffect(isEnabled: {
                    if self.ホバーエフェクト無効 {
                        false
                    } else {
                        self.モデル.駒を持ち上げたのは自分
                        &&
                        self.モデル.選択中の駒 != .なし
                    }
                }())
#endif
        }
    }
}
