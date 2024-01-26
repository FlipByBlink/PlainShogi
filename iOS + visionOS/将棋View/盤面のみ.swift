import SwiftUI

struct 盤面のみ: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 9) { 行 in
                if 行 != 0 { Divider() }
                HStack(spacing: 0) {
                    ForEach(0 ..< 9) { 列 in
                        if 列 != 0 { Divider() }
                        Self.盤上のコマもしくはマス(行 * 9 + 列)
                    }
                }
            }
        }
        .border(.primary, width: self.枠線の太さ)
        .frame(width: self.マスの大きさ * 9,
               height: self.マスの大きさ * 9)
    }
}

private extension 盤面のみ {
    private var 枠線の太さ: CGFloat {
        switch self.マスの大きさ {
            case ..<50: 1
            case 50..<100: 1.5
            case 100...: 2
            default: 1
        }
    }
    private struct 盤上のコマもしくはマス: View {
        @EnvironmentObject var モデル: アプリモデル
        private var 画面上での左上からの位置: Int
        private var 元々の位置: Int {
            モデル.上下反転 ? (80 - self.画面上での左上からの位置) : self.画面上での左上からの位置
        }
        private var 元々の場所: 駒の場所 {
            .盤駒(self.元々の位置)
        }
        var body: some View {
            Group {
                if モデル.局面.ここに駒がある(self.元々の場所) {
                    コマの見た目(self.元々の場所)
                        .onDrag { モデル.この駒をドラッグし始める(self.元々の場所) }
                } else { // ==== マス ====
                    Color(.systemBackground)
                }
            }
            .contentShape(.rect)
            .onTapGesture { モデル.この駒を選択する(self.元々の場所) }
            .onDrop(of: [.utf8PlainText],
                    delegate: ドロップデリゲート(モデル, .盤上(self.元々の位置)))
        }
        init(_ 画面上での左上からの位置: Int) {
            self.画面上での左上からの位置 = 画面上での左上からの位置
        }
    }
}
