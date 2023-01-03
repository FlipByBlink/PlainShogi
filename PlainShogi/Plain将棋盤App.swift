import SwiftUI

@main
struct Plain将棋盤App: App {
    @StateObject var 📱 = 📱アプリモデル()
    @StateObject var 🛒 = 🛒Storeモデル()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBar(hidden: true)
                .overlay(alignment: .bottomTrailing) { 🛠メニューボタン() }
                .sheet(isPresented: $📱.🚩メニューを表示) { 🛠アプリメニュー() }
                .modifier(初回起動時に駒の動かし方の説明アラート())
                .overlay(alignment: .bottom) { 📣広告バナー() }
                .task { UIApplication.shared.isIdleTimerDisabled = true }
                .environmentObject(📱)
                .environmentObject(🛒)
        }
    }
}

typealias 🛒Storeモデル = 🛒StoreModel
typealias 📣広告バナー = 📣ADBanner
