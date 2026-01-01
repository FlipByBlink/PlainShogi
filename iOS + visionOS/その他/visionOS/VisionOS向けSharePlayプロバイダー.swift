import SwiftUI
import LinkPresentation

struct VisionOS向けSharePlayプロバイダー: ViewModifier {
    func body(content: Content) -> some View {
        content
#if os(visionOS)
            .overlay(alignment: .topTrailing) {
                ShareLink(
                    item: 🄶roupActivity(),
                    preview: .init("将棋盤", icon: Image(.preview))
                )
                .hidden()
            }
#endif
    }
}

/* ==== 参照 ====
"近くにいるユーザーとvisionOSの体験を共有 - WWDC25 - ビデオ - Apple Developer"
https://developer.apple.com/jp/videos/play/wwdc2025/318?time=381

/* (書き起こし)
まず ボードゲームアプリ用のシンプルな GroupActivityを作成します 名称はBoardGameActivityです GroupActivitiesは SharePlayを 強化するフレームワークであり GroupActivityの定義は 共有体験を作成するための最初の手順です また ゲームのメインシーンを設定するため ボリュメトリックのWindowGroupで BoardGameViewを指定します SwiftUIアプリであるため 共有メニューに BoardGameActivityを公開するには ビューの階層に ShareLinkを追加する必要があります BoardGameActivityを渡すのは それが開始すべき対象だからであり 非表示にしたのは アプリのUIに影響を与えないためです 公開したアクティビティが 共有メニューから共有されると 自動的に有効化され GroupSessionが作成されます この仕組みは GroupActivityでactivate()メソッドを 手動で呼び出す場合と同様です
*/

/* (サンプルコード)
struct BoardGameActivity: GroupActivity, Transferable {
    var metadata: GroupActivityMetadata = {
        var metadata = GroupActivityMetadata()
        metadata.title = "Play Together"
        return metadata
    }()
}

struct BoardGameApp: App {
    var body: some Scene {
        WindowGroup {
            BoardGameView()
            ShareLink(item: BoardGameActivity(), preview: SharePreview("Play Together"))
                .hidden()
        }
        .windowStyle(.volumetric)
    }
}
*/

======================================== */
