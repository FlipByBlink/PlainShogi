import SwiftUI

struct メニューボタン: View { // ⚙️
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
#if !targetEnvironment(macCatalyst)
        Button {
            if self.モデル.表示中のシート == nil {
                モデル.表示中のシート = .メニュー
            } else {
                モデル.表示中のシート = nil
            }
            //共有シートとの競合が起きた場合のワークアラウンドとしてtoggleっぽく実装
        } label: {
            self.ラベル()
        }
        .contextMenu {
            強調表示クリアボタン()
            盤面初期化ボタン()
            増減モード開始ボタン()
            一手戻すボタン()
            self.上下反転ボタン()
            self.履歴ボタン()
            self.ブックマーク表示ボタン()
            self.駒の選択解除ボタン()
        }
        .modifier(Self.IOS向け装飾())
        .accessibilityLabel("メニューを開く")
#else
        EmptyView()
#endif
    }
}

private extension メニューボタン {
    private func ラベル() -> some View {
        Image(systemName: モデル.セリフ体 ? "gear" : "gearshape")
#if os(iOS)
            .font(.title2.weight(.light))
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(8)
#endif
    }
    private struct IOS向け装飾: ViewModifier {
        func body(content: Content) -> some View {
#if os(iOS)
            content
                .hoverEffect(.highlight)
                .padding(.trailing)
                .tint(.primary)
#else
            content
#endif
        }
    }
    private func 上下反転ボタン() -> some View {
        Button {
            モデル.上下反転.toggle()
            システムフィードバック.成功()
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
