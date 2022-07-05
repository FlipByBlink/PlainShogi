
import SwiftUI

@main
struct Plain将棋盤App: App {
    
    @ObservedObject var 📱 = 📱AppModel()
    
    let 🛒 = 🛒StoreModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBar(hidden: true)
                .overlay(alignment: .bottomTrailing) {
                    🛠メニューボタン()
                }
                .sheet(isPresented: $📱.🚩メニューを表示) {
                    🛠MenuSheet()
                        .onDisappear { 📱.🚩メニューを表示 = false } //TODO: これ必要かどうか再検討
                }
                .overlay(alignment: .bottom) {
                    📣ADBanner()
                }
                .environmentObject(📱)
                .environmentObject(🛒)
        }
    }
}
