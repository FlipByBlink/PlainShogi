import SwiftUI

struct ツールボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    private var 駒を選択していない: Bool { モデル.選択中の駒 == .なし }
    private var モード: Self.モード切り替え {
        if モデル.増減モード中 { return .増減モード完了 }
        return (モデル.選択中の駒 == .なし) ? .メニュー : .駒選択解除
    }
    var body: some View {
        Button(action: self.アクション) {
            Image(systemName: self.モード.アイコン)
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
        switch self.モード {
            case .メニュー:
                モデル.表示中のシート = .メニュー
                システムフィードバック.軽め()
            case .駒選択解除:
                モデル.駒の選択を解除する()
                システムフィードバック.軽め()
            case .増減モード完了:
                モデル.増減モードを終了する()
        }
    }
    private enum モード切り替え {
        case メニュー, 駒選択解除, 増減モード完了
        var アイコン: String {
            switch self {
                case .メニュー: "gearshape"
                case .駒選択解除: "escape"
                case .増減モード完了: "checkmark.circle.fill"
            }
        }
    }
}
