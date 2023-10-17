import SwiftUI

struct ContentView: View {
    var body: some View {
        将棋View()
            .overlay(alignment: .trailing) { 増減モード完了ボタン() }
            .modifier(シート管理())
            .modifier(サイドバー())
            .modifier(ICloudデータ.アクティブ復帰時に明示的に同期())
            .environment(\.layoutDirection, .leftToRight)
    }
}
