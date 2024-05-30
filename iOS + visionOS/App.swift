import SwiftUI

@main
struct アプリ: App {
    @UIApplicationDelegateAdaptor var モデル: アプリモデル
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands { コマンド(モデル) }
#if os(visionOS)
        .windowResizability(.contentMinSize)
#endif
        
#if os(visionOS)
        ImmersiveSpace(id: "immersiveSpace") {
            将棋View()
                .glassBackgroundEffect()
                .frame(width: 800, height: 800)
                .rotationEffect(.degrees(90))
                .rotation3DEffect(.degrees(90), axis: .x)
                .offset(y: -1500)
                .offset(z: -700)
        }
#endif
    }
}
