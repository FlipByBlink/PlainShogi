import SwiftUI

@main
struct アプリ: App {
    @StateObject private var モデル = アプリモデル()
    @StateObject private var アプリ内課金 = アプリ内課金モデル(id: "PlainShogi.adfree")
    @UIApplicationDelegateAdaptor var delegate: MacCatalyst調整.Delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(モデル)
                .environmentObject(アプリ内課金)
        }
        .commands { コマンド(モデル) }
    }
}
