import SwiftUI

struct ContentView: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.physicalMetrics) var physicalMetrics
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    var body: some View {
        VStack(spacing: 0) {
            将棋View()
            SharePlayインジケーター.IOS()
        }
        .padding(固定値.全体パディング)
        .padding(.top, 8)
        .modifier(ツールボタンズ())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .modifier(MacCatalyst調整.TitleBar隠し())
        .modifier(バックグラウンド時に駒選択を解除())
        .modifier(自動スリープ無効化())
        .modifier(ユーザーレビュー依頼())
        .modifier(ICloudデータ.アクティブ復帰時に明示的に同期())
        .modifier(SharePlay環境構築())
        .modifier(シート管理())
        .modifier(アプリ内課金ハンドラー())
        .modifier(VisionOS向けウインドウサイズ())
        .modifier(VisionOS向け暗転モード())
//        .overlay(alignment: .bottom) {
////            let size = 600.0
//            let size = physicalMetrics.convert(0.4, from: .meters)
//            将棋View()
//                .glassBackgroundEffect(in: .rect(cornerRadius: 16))
//                .frame(width: size, height: size)
//                .rotationEffect(.degrees(90))
//                .rotation3DEffect(.degrees(90), axis: .x)
//                .offset(z: 300)
//        }
        .task {
            await openImmersiveSpace(id: "immersiveSpace")
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}
