import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            将棋全体View()
                .modifier(将棋レイアウト.推定())
            🛠SharePlayインジケーターやメニューボタン()
        }
        .padding()
        .overlay(alignment: .bottomTrailing) { 🛠非SharePlay時のメニューボタン() }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .modifier(🛠メニューシート())
        .modifier(🗄️初回起動時に駒の動かし方の説明バナー())
        .modifier(🗄️自動スリープ無効化())
        .modifier(📣広告コンテンツ())
        .modifier(👥SharePlay環境構築())
    }
}
