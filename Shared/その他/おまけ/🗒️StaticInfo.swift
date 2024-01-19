import SwiftUI

enum 🗒️StaticInfo {
    static let appName: LocalizedStringKey = "Plain将棋盤"
    static let appSubTitle: LocalizedStringKey = "iPhone / iPad / Apple Watch / Mac / Apple TV / Apple Vision Pro"
    
    static let appStoreProductURL = URL(string: "https://apps.apple.com/app/id1620268476")!
    static var appStoreUserReviewURL: URL { .init(string: "\(Self.appStoreProductURL)?action=write-review")! }
    
    static var contactAddress: String { "sear_pandora_0x@icloud.com" }
    
    static let privacyPolicyDescription = """
        2022-04-21
        
        
        日本語(Japanese)
        
        このアプリ自身において、ユーザーの情報を一切収集しません。
        
        
        English
        
        This application don't collect user infomation.
        """
    
    static let webRepositoryURL = URL(string: "https://github.com/FlipByBlink/PlainShogi")!
    static let webMirrorRepositoryURL = URL(string: "https://gitlab.com/FlipByBlink/PlainShogi_Mirror")!
}

#if os(iOS)
extension 🗒️StaticInfo {
    static let versionInfos: [(version: String, date: String)] = [("1.6", "2024-02-??"),
                                                                  ("1.5.1", "2023-11-10"),
                                                                  ("1.5", "2023-10-27"),
                                                                  ("1.4", "2023-05-11"),
                                                                  ("1.3", "2023-01-22"),
                                                                  ("1.2.2", "2022-08-18"),
                                                                  ("1.2.1", "2022-07-21"),
                                                                  ("1.2", "2022-07-09"),
                                                                  ("1.1", "2022-05-07"),
                                                                  ("1.0", "2022-04-21")] //降順。先頭の方が新しい
    
    enum SourceCodeCategory: String, CaseIterable, Identifiable {
        case main, アプリモデル, 将棋モデル, 将棋View, サブView, メニュー, SharePlay, ドラッグアンドドロップ, 共有アイテム, フィードバック, その他, おまけ
        var id: Self { self }
        var fileNames: [String] {
            switch self {
                case .main: [
                    "App.swift",
                    "ContentView.swift"
                ]
                case .アプリモデル: [
                    "アプリモデル.swift",
                    "アプリモデルのスーパークラス.swift"
                ]
                case .将棋モデル: [
                    "局面モデル.swift",
                    "王側か玉側か.swift",
                    "盤上の駒.swift",
                    "持ち駒.swift",
                    "駒の場所.swift",
                    "駒の移動先パターン.swift",
                    "手前か対面か.swift",
                    "駒の種類.swift",
                    "空の手駒.swift"
                ]
                case .将棋View: [
                    "将棋View.swift",
                    "レイアウト.swift",
                    "成駒確認アラート.swift",
                    "操作エリア外で駒選択を解除.swift",
                    "字体.swift",
                    "オプション変更アニメーション.swift",
                    "EnvironmentValues拡張.swift"
                ]
                case .サブView: [
                    "ツールボタンズ.swift",
                    "シートカテゴリ.swift",
                    "シート管理.swift",
                    "増減モード.swift"
                ]
                case .メニュー: [
                    "メニュートップ.swift",
                    "メニューボタン.swift",
                    "コマンドボタンズ.swift",
                    "見た目カスタマイズメニュー.swift",
                    "履歴メニュー.swift",
                    "ブックマークメニュー.swift",
                    "共有メニュー.swift",
                    "局面プレビュー.swift",
                    "不具合フィードバックメニュー.swift"
                ]
                case .SharePlay: [
                    "GroupActivity.swift",
                    "SharePlay環境構築.swift",
                    "SharePlayインジケーター.swift",
                    "SharePlayガイドメニュー.swift",
                    "SharePlay紹介メニュー.swift",
                    "SharePlay用選択中の駒モデル.swift"
                ]
                case .ドラッグアンドドロップ: [
                    "ドラッグ対象.swift",
                    "ドロップデリゲート.swift"
                ]
                case .共有アイテム: [
                    "メイン画面の共有ボタン.swift",
                    "画像書き出し.swift",
                    "画像キャッシュハンドラー.swift",
                    "テキスト連携機能.swift",
                    "テキスト共有メニューコンポーネンツ.swift",
                    "画像共有メニューコンポーネンツ.swift"
                ]
                case .フィードバック: [
                    "フィードバックモデル.swift",
                    "システムフィードバック.swift",
                    "音声フィードバックモデル.swift"
                ]
                case .その他: [
                    "ICloudデータ.swift",
                    "フィードバック.swift",
                    "不特定エラー.swift",
                    "コマンド.swift",
                    "固定値.swift",
                    "バックグラウンド時に駒選択を解除.swift",
                    "自動スリープ無効化.swift",
                    "MacCatalyst.swift",
                    "広告コンテンツ.swift",
                    "アプリ内課金ハンドラー.swift",
                    "ユーザーレビュー依頼.swift"
                ]
                case .おまけ: [
                    "🗒️StaticInfo.swift",
                    "ℹ️AboutApp.swift",
                    "📣ADModel.swift",
                    "📣ADComponents.swift",
                    "🛒InAppPurchaseModel.swift",
                    "🛒InAppPurchaseView.swift"
                ]
            }
        }
    }
}

#elseif os(watchOS)
extension 🗒️StaticInfo {
    enum SourceCodeCategory: String, CaseIterable, Identifiable {
        case main, アプリモデル, 将棋モデル, 将棋View, サブView, メニュー, フィードバック, その他, おまけ, Widget
        var id: Self { self }
        var fileNames: [String] {
            switch self {
                case .main: [
                    "App.swift",
                    "ContentView.swift"
                ]
                case .アプリモデル: [
                    "アプリモデル.swift",
                    "アプリモデルのスーパークラス.swift"
                ]
                case .将棋モデル: [
                    "局面モデル.swift",
                    "王側か玉側か.swift",
                    "盤上の駒.swift",
                    "持ち駒.swift",
                    "駒の場所.swift",
                    "駒の移動先パターン.swift",
                    "手前か対面か.swift",
                    "駒の種類.swift",
                    "空の手駒.swift"
                ]
                case .将棋View: [
                    "将棋View.swift",
                    "字体.swift",
                    "EnvironmentValues拡張.swift"
                ]
                case .サブView: [
                    "ツールボタン.swift",
                    "シートカテゴリ.swift",
                    "増減モード.swift",
                    "閉じるボタン.swift"
                ]
                case .メニュー: [
                    "メニュー.swift",
                    "局面プレビュー.swift",
                    "アプリについて.swift"
                ]
                case .フィードバック: [
                    "フィードバックモデル.swift",
                    "システムフィードバック.swift",
                    "音声フィードバックモデル.swift"
                ]
                case .その他: [
                    "ICloudデータ.swift",
                    "フィードバック.swift",
                    "不特定エラー.swift"
                ]
                case .おまけ: [
                    "🗒️StaticInfo.swift"
                ]
                case .Widget: [
                    "ウィジェット.swift"
                ]
            }
        }
    }
}
#endif
