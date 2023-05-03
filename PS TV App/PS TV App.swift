import SwiftUI

@main
struct PS_TV_App: App {
    @StateObject private var 📱 = 📱アプリモデル()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(📱)
        }
    }
}
