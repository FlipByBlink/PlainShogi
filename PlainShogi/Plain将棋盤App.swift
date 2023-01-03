import SwiftUI

@main
struct Plain将棋盤App: App {
    @ObservedObject var 📱 = 📱AppModel()
    let 🛒 = 🛒StoreModel()
    var body: some Scene {
        WindowGroup {
            ContentView_段筋付き()
                .statusBar(hidden: true)
                .overlay(alignment: .bottomTrailing) { 🛠メニューボタン() }
                .sheet(isPresented: $📱.🚩メニューを表示) { 🛠AppMenu() }
                .overlay(alignment: .bottom) { 📣ADBanner() }
                .task { UIApplication.shared.isIdleTimerDisabled = true }
                .environmentObject(📱)
                .environmentObject(🛒)
        }
    }
}
