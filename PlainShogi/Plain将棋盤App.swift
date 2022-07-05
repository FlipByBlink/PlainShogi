
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
                    🛠MenuButton()
                        .disabled(📱.駒を整理中)
                }
                .overlay(alignment: .topLeading) {
                    if 📱.駒を整理中 {
                        整理完了ボタン()
                    }
                }
                .overlay(alignment: .bottom) {
                    📣ADBanner()
                }
                .environmentObject(📱)
                .environmentObject(🛒)
        }
    }
}
