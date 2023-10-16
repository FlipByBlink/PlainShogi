import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            将棋View()
            SharePlayインジケーター()
        }
        .padding(固定値.全体パディング)
        .modifier(ツールボタン())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .modifier(MacCatalyst調整.titleBar隠し())
        .modifier(バックグラウンド時に駒選択を解除())
        .modifier(自動スリープ無効化())
        .modifier(ユーザーレビュー依頼())
        .modifier(ICloudデータ.アクティブ復帰時に明示的に同期())
        .modifier(SharePlay環境構築())
        .modifier(シート管理())
        .environment(\.layoutDirection, .leftToRight)
    }
}
