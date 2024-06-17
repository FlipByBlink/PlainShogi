import SwiftUI
import GroupActivities

struct VisionOS向け空間無同期テキスト: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
#if os(visionOS)
            .safeAreaInset(edge: .bottom) {
                if モデル.グループセッション?.state == .joined {
                    Text("このメニュー表示は同期していません")
                        .foregroundStyle(.secondary)
                        .font(.subheadline.weight(.semibold))
                        .padding()
                        .glassBackgroundEffect()
                        .padding()
                }
            }
#endif
    }
}
