
import SwiftUI

@main
struct Plain将棋盤App: App {
    
    let 📱 = 📱AppModel()
    
    let 🛒 = 🛒StoreModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBar(hidden: true)
                .overlay(alignment: .bottomTrailing) {
                    🛠MenuButton()
                }
                .overlay(alignment: .bottom) {
                    📣ADBanner()
                }
                .environmentObject(📱)
                .environmentObject(🛒)
        }
    }
}
