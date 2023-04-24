import SwiftUI

@main
struct Plain将棋盤App: App {
    @StateObject private var 📱 = 📱アプリモデル()
    @StateObject private var 🛒 = 🛒Storeモデル(id: "PlainShogi.adfree")
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modifier(🗄️初回起動時に駒の動かし方の説明バナー())
                .modifier(🗄️自動スリープ無効化())
                .modifier(📣広告コンテンツ())
                .modifier(👥SharePlay環境構築())
                .environmentObject(📱)
                .environmentObject(🛒)
        }
    }
}
