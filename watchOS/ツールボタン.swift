import SwiftUI

struct ツールボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    private var 駒を選択していない: Bool { モデル.選択中の駒 == .なし }
    var body: some View {
        Button(action: self.アクション) {
            Image(systemName: モデル.増減モード中 ? "checkmark.circle.fill" : "gearshape")
                .resizable()
                .scaledToFit()
                .padding(9)
                .frame(width: self.マスの大きさ * 2, height: self.マスの大きさ + 12)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(item: $モデル.表示中のシート) {
            switch $0 {
                case .メニュー: メニュートップ()
                case .手駒増減(let 陣営): 手駒増減メニュー(陣営)
                default: Text(verbatim: "⚠︎")
            }
        }
        .animation(.default, value: self.駒を選択していない)
    }
    private func アクション() {
        if モデル.増減モード中 {
            モデル.増減モードを終了する()
        } else {
            モデル.表示中のシート = .メニュー
            システムフィードバック.軽め()
        }
    }
}
