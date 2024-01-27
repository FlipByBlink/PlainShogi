import SwiftUI

@main
struct アプリ: App {
    @UIApplicationDelegateAdaptor var モデル: アプリモデル
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands { コマンド(モデル) }
#if os(visionOS)
        .windowResizability(.contentMinSize)
#endif
    }
}
