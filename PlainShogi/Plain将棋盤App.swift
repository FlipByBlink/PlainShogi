import SwiftUI

@main
struct Plain将棋盤App: App {
    @StateObject var 📱 = 📱AppModel()
    @StateObject var 🛒 = 🛒StoreModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBar(hidden: true)
                .overlay(alignment: .bottomTrailing) { 🛠メニューボタン() }
                .sheet(isPresented: $📱.🚩メニューを表示) { 🛠AppMenu() }
                .modifier(初回起動時に駒の動かし方の説明アラート())
                .overlay(alignment: .bottom) { 📣ADBanner() }
                .task { UIApplication.shared.isIdleTimerDisabled = true }
                .environmentObject(📱)
                .environmentObject(🛒)
        }
    }
}
