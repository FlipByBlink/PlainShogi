import SwiftUI
import GroupActivities

struct コマンド: Commands {
    @ObservedObject var モデル: アプリモデル
    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("メニューを表示") { モデル.表示中のシート = .メニュー }
                .keyboardShortcut(",")
                .disabled(モデル.表示中のシート == .広告)
        }
        CommandMenu("操作") {
            Group {
                Button("一手だけ戻す") { モデル.一手戻す() }
                    .keyboardShortcut("z", modifiers: [])
                Button("履歴を表示") { モデル.表示中のシート = .履歴 }
                    .keyboardShortcut("y", modifiers: [])
                    .disabled(局面モデル.履歴.isEmpty)
                Button("ブックマークを表示") { モデル.表示中のシート = .ブックマーク }
                    .keyboardShortcut("d", modifiers: [])
                Button("駒増減モードを開始") { モデル.増減モードを開始する() }
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(モデル.増減モード中)
                Button("盤面を初期化") { モデル.盤面を初期化する() }
                    .keyboardShortcut(.delete)
                Button("強調表示をクリア") { モデル.強調表示をクリア() }
                    .keyboardShortcut(.delete, modifiers: [.command, .shift])
                Button("駒の選択を解除") { モデル.駒の選択を解除する() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(モデル.選択中の駒 == .なし)
                Button("テキストとしてコピー") { モデル.現在の局面をテキストとしてコピー() }
                    .keyboardShortcut("c", modifiers: [])
                Button("テキストを局面としてペースト") { モデル.テキストを局面としてペースト() }
                    .keyboardShortcut("v", modifiers: [])
                self.SharePlayメニューボタン()
            }
            .disabled(モデル.表示中のシート == .広告)
        }
        CommandMenu("見た目") { Self.見た目コマンド() }
    }
    @StateObject private var groupStateObserver = GroupStateObserver()
    private func SharePlayメニューボタン() -> some View {
        Button("SharePlayメニューを表示") { モデル.表示中のシート = .SharePlayガイド }
            .disabled(!self.groupStateObserver.isEligibleForGroupSession)
    }
    private struct 見た目コマンド: View {
        @AppStorage("上下反転") var 上下反転: Bool = false
        @AppStorage("セリフ体") var セリフ体: Bool = false
        @AppStorage("太字") var 太字: Bool = false
        @AppStorage("サイズ") var サイズ: 字体.サイズ = .標準
        @AppStorage("English表記") var english表記: Bool = false
        @AppStorage("直近操作強調表示機能オフ") var 直近操作強調オフ: Bool = false
        var body: some View {
            Toggle("上下反転", isOn: self.$上下反転)
            Toggle("セリフ体", isOn: self.$セリフ体)
            Toggle("太字", isOn: self.$太字)
            Picker("駒のサイズ", selection: self.$サイズ) {
                ForEach(字体.サイズ.allCases) { Text($0.ローカライズキー) }
            }
            Toggle("English表記", isOn: self.$english表記)
            Toggle("操作した直後の駒の強調表示を常に無効", isOn: self.$直近操作強調オフ)
        }
    }
    init(_ モデル: アプリモデル) { self.モデル = モデル }
}
