import SwiftUI

enum VisionOS向けHoverEffect {
    struct コマ: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        func body(content: Content) -> some View {
            content
#if os(visionOS)
                .hoverEffect(isEnabled: {
                    if self.モデル.選択中の駒 == .なし {
                        true
                    } else {
                        if self.モデル.駒を持ち上げたのは自分 {
                            true
                        } else {
                            false
                        }
                    }
                }())
#endif
        }
    }
    struct マス: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        func body(content: Content) -> some View {
            content
#if os(visionOS)
                .border(.gray.opacity(0.001), width: 0.001) //Workaround
                .hoverEffect(isEnabled: {
                    self.モデル.駒を持ち上げたのは自分
                    &&
                    self.モデル.選択中の駒 != .なし
                }())
#endif
        }
    }
}
