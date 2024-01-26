import SwiftUI

struct 盤面のコマもしくはマス: View {
    @EnvironmentObject var モデル: アプリモデル
    private var 画面上での左上からの位置: Int
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

private extension 盤面のコマもしくはマス {
    private var 元々の位置: Int {
        モデル.上下反転 ? (80 - self.画面上での左上からの位置) : self.画面上での左上からの位置
    }
    private var 元々の場所: 駒の場所 {
        .盤駒(self.元々の位置)
    }
}
