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
            Label {
                Text("強調表示をクリア")
                    .opacity(self.無効化 ? 0.33 : 1)
            } icon: {
                Image(systemName: "square.dashed")
            }
        }
        .disabled(self.無効化)
    }
    private var 無効化: Bool {
        モデル.何も強調表示されていない
        ||
        モデル.強調表示常時オフかつ駒が選択されていない
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
            Label{
                Text("一手だけ戻す")
                    .opacity(self.無効化 ? 0.33 : 1)
            } icon: {
                Image(systemName: "arrow.backward.to.line")
            }
        }
        .disabled(self.無効化)
    }
    private var 無効化: Bool { モデル.局面.一手前の局面 == nil }
}

struct 駒を裏返すボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        Button {
            モデル.選択中の駒を裏返す()
        } label: {
            Label {
                Text("駒を裏返す")
                    .opacity(self.無効化 ? 0.33 : 1)
            } icon: {
                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
            }
        }
        .disabled(self.無効化)
    }
    private var 無効化: Bool {
        if case .盤駒(_) = モデル.選択中の駒 {
            false
        } else {
            true
        }
    }
}
