import SwiftUI
import GroupActivities

struct VisionOS向け空間無同期テキスト: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
#if os(visionOS)
            .safeAreaInset(edge: .bottom) {
                if モデル.グループセッション?.state == .joined {
                    Text("この画面は相手には見えていません")
                        .font(.title3)
                        .bold()
                        .kerning(2)
                        .padding()
                        .background {
                            Capsule()
                                .fill(.regularMaterial)
                                .strokeBorder(.primary, lineWidth: 2)
                        }
                        .padding()
                }
            }
#endif
    }
}
