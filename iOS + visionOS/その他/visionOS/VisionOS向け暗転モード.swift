import SwiftUI

struct VisionOS向け暗転モード: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
#if os(visionOS)
            .preferredSurroundingsEffect(モデル.暗転モード ? .systemDark : .none)
#endif
    }
}

extension VisionOS向け暗転モード {
    struct トグル: View {
        @EnvironmentObject var モデル: アプリモデル
        var body: some View {
#if os(visionOS)
            Toggle(isOn: self.$モデル.暗転モード) {
                Label("周りを少し暗くする", systemImage: "roman.shade.closed")
            }
#else
            EmptyView()
#endif
        }
    }
}
