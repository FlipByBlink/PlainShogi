import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            将棋View_tvOSApp()
                .overlay(alignment: .leading) { メニューボタン() }
        }
        .modifier(シート())
        .modifier(💾アクティブ復帰時にiCloudを明示的に同期())
        .environment(\.layoutDirection, .leftToRight)
    }
}

struct シート: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .sheet(item: $📱.シートを表示) {
                switch $0 {
                    case .メニュー:
                        メニューコンテンツ()
                    case .手駒増減(let 陣営):
                        🪄手駒増減メニュー(陣営)
                    default:
                        Text("Placeholder")
                }
            }
    }
}
