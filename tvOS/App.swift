import SwiftUI

@main
struct アプリ: App {
    @StateObject private var モデル = アプリモデル()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task { await モデル.新規GroupSessionを受信したら設定する() }
                .environmentObject(モデル)
        }
    }
}
