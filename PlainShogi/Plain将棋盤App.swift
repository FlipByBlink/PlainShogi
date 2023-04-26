import SwiftUI

@main
struct Plain将棋盤App: App {
    @StateObject private var 📱 = 📱アプリモデル()
    @StateObject private var 🛒 = 🛒Storeモデル(id: "PlainShogi.adfree")
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(📱)
                .environmentObject(🛒)
        }
    }
}
