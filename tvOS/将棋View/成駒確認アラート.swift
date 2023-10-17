import SwiftUI

struct 成駒確認アラート: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .alert("成りますか？", isPresented: $モデル.成駒確認アラートを表示) {
                Button("成る") { モデル.今移動した駒を成る() }
                Button("キャンセル", role: .cancel) { モデル.成駒確認アラートを表示 = false }
            } message: {
                Text(モデル.成駒確認メッセージ)
            }
    }
}
