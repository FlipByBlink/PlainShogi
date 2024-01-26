import SwiftUI

struct 駒テキスト: View {
    var 字: String
    var 対象: 字体.対象カテゴリ = .コマ
    var 強調: Bool = false
    var 下線: Bool = false
    @Environment(\.マスの大きさ) var マスの大きさ
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    @AppStorage("太字") private var 太字オプション: Bool = false
    @AppStorage("サイズ") private var サイズ: 字体.サイズ = .標準
    // ↑ ドラッグプレビューのためにEnvironmentObjectを避ける必要あり
    var body: some View {
        Text(字体.装飾(self.字,
                   フォント: .system(size: self.サイズポイント,
                                 weight: self.太字適用 ? .bold : .regular,
                                 design: self.セリフ体 ? .serif : .default),
                   下線: self.下線))
        .minimumScaleFactor(0.5)
    }
}

private extension 駒テキスト {
    private var サイズポイント: CGFloat {
        switch self.対象 {
            case .コマ, .段筋: self.マスの大きさ * self.サイズ.比率(self.対象)
            case .プレビュー(let コマの大きさ): コマの大きさ * self.サイズ.比率(self.対象)
        }
    }
    private var 太字適用: Bool {
        self.強調 || self.太字オプション
    }
}
