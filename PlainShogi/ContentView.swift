import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            将棋View()
            🛠SharePlayインジケーターやメニューボタン()
        }
        .padding(🗄️固定値.全体パディング)
        .modifier(🛠非SharePlay時のメニューボタン())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .modifier(🗄️MacCatalyst.微調整())
        .modifier(🗄️自動スリープ無効化())
        .modifier(💾アクティブ復帰時にiCloudを明示的に同期())
        .modifier(👥SharePlay環境構築())
        .modifier(🗄️RequestUserReview())
        .modifier(🪧シート())
    }
}
