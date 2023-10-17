import SwiftUI

@main
struct アプリ: App {
    @StateObject private var モデル = アプリモデル()
//    @UIApplicationDelegateAdaptor var delegate: MacCatalyst調整.Delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(モデル)
        }
        .commands { コマンド(モデル) }
    }
}
