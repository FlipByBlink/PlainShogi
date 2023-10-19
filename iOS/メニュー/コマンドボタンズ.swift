import SwiftUI

struct 盤面初期化ボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        Button {
            モデル.盤面を初期化する()
        } label: {
            Label("盤面を初期化", systemImage: "arrow.counterclockwise")
        }
    }
}

struct 強調表示クリアボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        Button {
            モデル.強調表示をクリア()
        } label: {
            Label("強調表示をクリア", systemImage: "square.dashed")
        }
        .disabled(モデル.何も強調表示されていない)
        .disabled(モデル.強調表示常時オフかつ駒が選択されていない)
    }
}

struct 増減モード開始ボタン: View {
    var タイトル: LocalizedStringKey = "駒を増減"
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        Button {
            モデル.増減モードを開始する()
        } label: {
            Label(self.タイトル, systemImage: "wand.and.rays")
        }
    }
}

struct 一手戻すボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        Button {
            モデル.一手戻す()
        } label: {
            Label("一手だけ戻す", systemImage: "arrow.backward.to.line")
        }
        .disabled(モデル.局面.一手前の局面 == nil)
    }
}
