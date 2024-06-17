import SwiftUI

enum VisionOS向けHoverEffect {
    struct コマ: ViewModifier {
        func body(content: Content) -> some View {
            content
#if os(visionOS)
                .hoverEffect()
#endif
        }
    }
    struct マス: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        func body(content: Content) -> some View {
            content
#if os(visionOS)
                .border(.gray.opacity(0.001), width: 0.001) //Workaround
                .hoverEffect(isEnabled: モデル.選択中の駒 != .なし)
#endif
        }
    }
}
