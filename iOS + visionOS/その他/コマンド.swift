import SwiftUI
import GroupActivities

struct コマンド: Commands {
    @ObservedObject var モデル: アプリモデル
    @AppStorage("効果音無効化") var 効果音無効化: Bool = false
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
                Button("テキストを局面としてペースト") { try? モデル.テキストを局面としてペースト() }
                    .keyboardShortcut("v", modifiers: [])
                Self.SharePlayメニューボタン(モデル: self.モデル)
            }
            .disabled(モデル.表示中のシート == .広告)
        }
        CommandMenu("カスタマイズ") {
            Toggle("上下反転", isOn: $モデル.上下反転)
            Toggle("セリフ体", isOn: $モデル.セリフ体)
            Toggle("太字", isOn: $モデル.太字)
            Picker("駒のサイズ", selection: $モデル.サイズ) {
                ForEach(字体.サイズ.allCases) { Text($0.ローカライズキー) }
            }
            Toggle("English表記", isOn: $モデル.english表記)
            Toggle("操作した直後の駒の強調表示を常に無効", isOn: $モデル.直近操作強調表示機能オフ)
            Toggle("効果音を無効", isOn: self.$効果音無効化)
        }
    }
    init(_ モデル: アプリモデル) { self.モデル = モデル }
}

private extension コマンド {
    private struct SharePlayメニューボタン: View {
        @StateObject private var groupStateObserver = GroupStateObserver()
        @ObservedObject var モデル: アプリモデル
        var body: some View {
            Button("SharePlayメニューを表示") { モデル.表示中のシート = .SharePlayガイド }
                .disabled(!self.groupStateObserver.isEligibleForGroupSession)
        }
    }
}
