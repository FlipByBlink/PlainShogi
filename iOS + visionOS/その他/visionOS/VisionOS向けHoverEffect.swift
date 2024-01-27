import SwiftUI

enum VisionOS向けHoverEffect {
    struct コマ: ViewModifier {
        func body(content: Content) -> some View {
#if os(visionOS)
            content.hoverEffect()
#else
            content
#endif
        }
    }
    struct マス: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        func body(content: Content) -> some View {
#if os(visionOS)
            content
                .border(.gray.opacity(0.001), width: 0.001) //Workaround
                .hoverEffect(isEnabled: モデル.選択中の駒 != .なし)
#else
            content
#endif
        }
    }
}
