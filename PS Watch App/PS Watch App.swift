import SwiftUI

@main
struct PS_Watch_App: App {
    @StateObject private var 📱 = 📱アプリモデル()
    var body: some Scene {
        WindowGroup {
            //ContentView_watchOSApp()
            将棋View()
                //.overlay { Color.cyan.opacity(0.5) }
                .environmentObject(📱)
        }
    }
}
