import SwiftUI

struct 駒選択を解除: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .onExitCommand(perform: モデル.選択中の駒 != .なし ? self.選択解除 : nil)
    }
    private func 選択解除() { モデル.駒の選択を解除する() }
}
