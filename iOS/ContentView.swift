import SwiftUI

struct ContentView: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        VStack(spacing: 0) {
            将棋View()
            SharePlayインジケーター()
        }
        .padding(固定値.全体パディング)
        .padding(.top, 8)
        .modifier(ツールボタンズ())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .modifier(MacCatalyst調整.TitleBar隠し())
        .modifier(バックグラウンド時に駒選択を解除())
        .modifier(自動スリープ無効化())
        .modifier(ユーザーレビュー依頼())
        .modifier(ICloudデータ.アクティブ復帰時に明示的に同期())
        .modifier(SharePlay環境構築())
        .modifier(シート管理())
        .modifier(共有ボタンや画像キャッシュ())
        .environment(\.layoutDirection, .leftToRight)
        .environmentObject(モデル.アプリ内課金管理)
    }
}
