import SwiftUI

struct ツールボタンズ: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @State private var サムネイル: Image = .init(.aboutAppIcon)
    func body(content: Content) -> some View {
        content
#if os(iOS)
            .toolbar {
                if モデル.増減モード中 {
                    ToolbarItem(placement: .topBarLeading) {
                        増減モード完了ボタン()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    メニューボタン()
                }
            }
            .animation(.default, value: モデル.増減モード中)
#elseif os(visionOS)
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    SharePlayインジケーター.VisionOS()
                    if モデル.増減モード中 {
                        増減モード完了ボタン()
                    } else {
                        メニューボタン()
                    }
                }
            }
#endif
            .modifier(画像キャッシュハンドラー(self.$サムネイル))
    }
}
