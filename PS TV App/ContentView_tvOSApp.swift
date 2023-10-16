import SwiftUI

struct ContentView: View {
    var body: some View {
        将棋View_tvOSApp()
            .overlay(alignment: .trailing) { 増減モード完了ボタン() }
            .modifier(シート())
            .modifier(サイドバー())
            .modifier(ICloudデータ.アクティブ復帰時に明示的に同期())
            .environment(\.layoutDirection, .leftToRight)
    }
}

private struct シート: ViewModifier {
    @EnvironmentObject private var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .sheet(item: $モデル.表示中のシート) {
                switch $0 {
                    case .メニュー: メニューコンテンツ()
                    case .手駒増減(let 陣営): 手駒増減メニュー(陣営)
                    default: Text(verbatim: "BUG")
                }
            }
    }
}
