import SwiftUI

enum 🔠フォント {
    enum サイズ: String, CaseIterable, Identifiable {
        case 小, 標準, 大, 最大
        var id: Self { self }
        func 比率(_ カテゴリ: 対象カテゴリ) -> Double {
            switch カテゴリ {
                case .コマ, .プレビュー:
                    switch self {
                        case .小: return 0.4
                        case .標準: return 0.5
                        case .大: return 0.65
                        case .最大: return 1.0
                    }
                case .段筋:
                    switch self {
                        case .小: return 0.3
                        case .標準: return 0.35
                        case .大: return 0.40
                        case .最大: return 0.45
                    }
            }
        }
        var ピッカーフォント: Font {
            switch self {
                case .小: return .caption
                case .標準: return .body
                case .大: return .title
                case .最大: return .largeTitle
            }
        }
        var ローカライズキー: LocalizedStringKey { .init(self.rawValue) }
    }
    enum 対象カテゴリ {
        case コマ, 段筋, プレビュー(_ コマの大きさ: CGFloat)
    }
    static func テキストを装飾(_ 字: String, サイズ: CGFloat, 太字: Bool = false, 下線: Bool = false) -> AttributedString {
        var 値 = AttributedString(stringLiteral: 字)
        値.font = .system(size: サイズ * 0.9, weight: 太字 ? .bold : .light)
        if 下線 { 値.underlineStyle = .single }
        値.languageIdentifier = "ja"
        return 値
    }
}
