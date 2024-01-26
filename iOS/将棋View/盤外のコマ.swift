import SwiftUI

struct 盤外のコマ: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    private var 場所: 駒の場所
    var body: some View {
        if self.数 > 0 {
            コマの見た目(self.場所)
                .frame(width: self.マスの大きさ * self.幅比率,
                       height: self.マスの大きさ)
                .onTapGesture { self.モデル.この駒を選択する(self.場所) }
                .onDrag {
                    モデル.この駒をドラッグし始める(self.場所)
                } preview: {
                    self.プレビュー()
                }
        }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        self.場所 = .手駒(ｼﾞﾝｴｲ, ｼｮｸﾒｲ)
    }
}

private extension 盤外のコマ {
    private var 数: Int {
        モデル.局面.この手駒の数(self.場所)
    }
    private var 幅比率: Double {
        self.数 >= 2 ? レイアウト.複数個の盤外コマの幅比率 : 1
    }
    private func プレビュー() -> some View {
        Self.手駒ドラッグプレビュー用コマ(モデル.この駒のプレビュー表記(self.場所) ?? "⚠︎",
                            self.マスの大きさ,
                            モデル.この駒は下向き(self.場所))
    }
    private struct 手駒ドラッグプレビュー用コマ: View {
        private var 表記: String
        private var コマの大きさ: CGFloat
        private var 上下反転: Bool
        var body: some View {
            ZStack {
                Color(.systemBackground)
                駒テキスト(字: self.表記,
                      対象: .プレビュー(self.コマの大きさ))
            }
            .frame(width: self.コマの大きさ, height: self.コマの大きさ)
            .rotationEffect(self.上下反転 ? .degrees(180) : .zero)
        }
        init(_ ﾋｮｳｷ: String, _ ｺﾏﾉｵｵｷｻ: CGFloat, _ ｼﾞｮｳｹﾞﾊﾝﾃﾝ: Bool) {
            (self.表記, self.コマの大きさ, self.上下反転) = (ﾋｮｳｷ, ｺﾏﾉｵｵｷｻ, ｼﾞｮｳｹﾞﾊﾝﾃﾝ)
        }
    }
}
