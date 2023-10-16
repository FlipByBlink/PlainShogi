import SwiftUI

enum 字体 {
    enum サイズ: String, CaseIterable, Identifiable {
        case 小, 標準, 大, 最大
        var id: Self { self }
        func 比率(_ カテゴリ: 対象カテゴリ) -> Double {
            switch カテゴリ {
                case .コマ, .プレビュー:
                    switch self {
                        case .小: 0.4
                        case .標準: 0.5
                        case .大: 0.65
                        case .最大: 1.0
                    }
                case .段筋:
                    switch self {
                        case .小: 0.3
                        case .標準: 0.35
                        case .大: 0.40
                        case .最大: 0.45
                    }
            }
        }
        var ローカライズキー: LocalizedStringKey { .init(self.rawValue) }
    }
    enum 対象カテゴリ {
        case コマ, 段筋, プレビュー(_ コマの大きさ: CGFloat)
    }
    static func 装飾(_ 字: String, フォント: Font, 下線: Bool = false) -> AttributedString {
        var 値 = AttributedString(stringLiteral: 字)
        値.font = フォント
        if 下線 { 値.underlineStyle = .single }
        値.languageIdentifier = "ja" //非日本語圏向け日本語駒の表示揺れ対策
        return 値
    }
}
