import SwiftUI

@main
struct Plain将棋盤App: App {
    @StateObject private var 📱 = 📱アプリモデル()
    @StateObject private var 🛒 = 🛒Storeモデル(id: "PlainShogi.adfree")
    @UIApplicationDelegateAdaptor private var ⓓelegate: 🗄️MacCatalyst.Delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(📱)
                .environmentObject(🛒)
        }
        .commands { 🗄️コマンド(📱) }
    }
}
