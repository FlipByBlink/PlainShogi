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

/* ==== 参照: "Build spatial SharePlay experiences - WWDC23 - Videos - Apple Developer" ====
https://developer.apple.com/wwdc23/10087?time=866

/* (書き起こし)
グループアクティビティの公開は AirDropでSharePlayを 始めるのと同じ方法で行います
iOS 17では SharePlayアプリを 開いておく事で AirDropでSharePlayが 始められるようになります
グループアクティビティをフェッチするのに システムは表示されているシーンの UIレスポンダチェーン内を探し そのうちの一つのレスポンダの アクティビティアイテム設定で 特定されているグループアクティビティを 見つけようとします
そうすると SharePlayコンテンツを 表示しているビューコントローラの アクティビティアイテム設定で グループアクティビティを設定できて それが自動的にピックアップされます
アクティビティアイテム設定を行うには まず 有効化できるアクティビティを 作ることから始めます
次に アイテムプロバイダを作成して そこに グループアクティビティを 登録します
それからアイテムプロバイダで UIActivityItemsConfigurationを 初期化します
最後は 設定が公開しているのが 正しいメタデータである事を 確認しましょう
それがShareメニューで表示されるからです
そのためには metadataProviderを UIActivityItemsConfigurationで使い LinkPresentationMetadataキーのために LPLinkMetadataオブジェクトを提供します
Shareメニューにはtitleと imageProviderが使われます
UIActivityItemsConfigurationReadingに 準拠する自分のクラスを使っても すべてこの通りに作業できます
*/

/* (サンプルコード)
let activity = ExploreActivity()
let itemProvider = NSItemProvider()
itemProvider.registerGroupActivity(activity)
let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])
configuration.metadataProvider = { key in
    guard key == .linkPresentationMetadata else { return nil }
    let metadata = LPLinkMetadata()
    metadata.title = "Explore Together"
    metadata.imageProvider = NSItemProvider(object: UIImage(named: "explore-activity")!)
    return metadata
}
self.activityItemsConfiguration = configuration
*/

================================================================ */
