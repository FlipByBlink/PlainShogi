import SwiftUI

struct 共有ボタンや画像キャッシュ: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @State private var サムネイル: Image = .init(.roundedIcon)
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topLeading) {
                Group {
                    if !モデル.増減モード中 { メイン画面の共有ボタン(self.$サムネイル) }
                }
                .animation(.default, value: モデル.増減モード中)
            }
            .modifier(画像キャッシュハンドラー(self.$サムネイル))
    }
}
