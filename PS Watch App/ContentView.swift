import SwiftUI

struct ContentView: View {
    var body: some View {
        将棋View()
            .modifier(ICloudデータ.アクティブ復帰時に明示的に同期())
            .environment(\.layoutDirection, .leftToRight)
    }
}
