import SwiftUI

struct VisionOS向けホバーエフェクト無効化トグル: View {
    @AppStorage("ホバーエフェクト無効") var ホバーエフェクト無効: Bool = false
    var body: some View {
#if os(visionOS)
        Toggle(isOn: self.$ホバーエフェクト無効) {
            Label("視線に反応するエフェクトを無効化",
                  systemImage: "eye.trianglebadge.exclamationmark")
        }
#endif
    }
}
