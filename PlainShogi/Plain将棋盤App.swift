import SwiftUI

@main
struct Plain将棋盤App: App {
    @StateObject private var 📱 = 📱アプリモデル()
    @StateObject private var 🛒 = 🛒Storeモデル(id: "PlainShogi.adfree")
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                ContentView()
                SharePlayインジケーターやメニューボタン()
            }
            .padding()
            .overlay(alignment: .bottomTrailing) { 🛠非SharePlay時のメニューボタン() }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .sheet(isPresented: $📱.🚩メニューを表示) { 🛠アプリメニュー() }
            .modifier(成駒確認アラート())
            .modifier(初回起動時に駒の動かし方の説明バナー())
            .modifier(📣広告コンテンツ())
            .task { UIApplication.shared.isIdleTimerDisabled = true }
            .modifier(SharePlay環境構築())
            .environmentObject(📱)
            .environmentObject(🛒)
        }
    }
}
