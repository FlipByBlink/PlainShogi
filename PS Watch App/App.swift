import SwiftUI

@main
struct アプリ: App {
    @StateObject private var モデル = アプリモデル()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(モデル)
        }
    }
}
