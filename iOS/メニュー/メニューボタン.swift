import SwiftUI

struct メニューボタン: View { // ⚙️
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
#if !targetEnvironment(macCatalyst)
        Menu {
            強調表示クリアボタン()
            盤面初期化ボタン()
            増減モード開始ボタン()
            一手戻すボタン()
            self.上下反転ボタン()
            self.履歴ボタン()
            self.ブックマーク表示ボタン()
            self.駒の選択解除ボタン()
        } label: {
            Image(systemName: モデル.セリフ体 ? "gear" : "gearshape")
                .font(.title2.weight(.light))
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .padding(8)
        } primaryAction: {
            モデル.表示中のシート = .メニュー
        }
        .hoverEffect(.highlight)
        .padding(.trailing)
        .tint(.primary)
        .accessibilityLabel("Open menu")
#else
        EmptyView()
#endif
    }
}

private extension メニューボタン {
    private func 上下反転ボタン() -> some View {
        Button {
            モデル.上下反転.toggle()
            フィードバック.成功()
        } label: {
            Label(モデル.上下反転 ? "上下反転を元に戻す" : "上下反転させる",
                  systemImage: "arrow.up.arrow.down")
        }
    }
    private func 履歴ボタン() -> some View {
        Button {
            モデル.表示中のシート = .履歴
        } label: {
            Label("履歴を表示", systemImage: "clock")
        }
    }
    private func ブックマーク表示ボタン() -> some View {
        Button {
            モデル.表示中のシート = .ブックマーク
        } label: {
            Label("ブックマークを表示", systemImage: "bookmark")
        }
    }
    private func 駒の選択解除ボタン() -> some View {
        Group {
            if モデル.選択中の駒 != .なし {
                Button {
                    モデル.駒の選択を解除する()
                } label: {
                    Label("駒の選択を解除", systemImage: "square.slash")
                }
            }
        }
    }
}
