import SwiftUI

struct ContentView: View {
    var body: some View {
        将棋View_tvOSApp()
            .overlay(alignment: .trailing) { 🪄増減モード完了ボタン() }
            .modifier(シート())
            .modifier(🛠サイドバー())
            .modifier(自動スリープ無効化())
            .modifier(💾アクティブ復帰時にiCloudを明示的に同期())
            .environment(\.layoutDirection, .leftToRight)
    }
}

private struct シート: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .sheet(item: $📱.シートを表示) {
                switch $0 {
                    case .メニュー: 🛠メニューコンテンツ()
                    case .手駒増減(let 陣営): 🪄手駒増減メニュー(陣営)
                    default: Text("🐛")
                }
            }
    }
}

struct 自動スリープ無効化: ViewModifier { //TODO: 再検討
    func body(content: Content) -> some View {
        content
            .task { UIApplication.shared.isIdleTimerDisabled = true }
    }
}
