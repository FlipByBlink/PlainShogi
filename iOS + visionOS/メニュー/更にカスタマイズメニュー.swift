import SwiftUI
import GroupActivities

struct 更にカスタマイズメニューリンク: View {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject private var groupStateObserver = GroupStateObserver()
    @AppStorage("効果音無効化") var 効果音無効化: Bool = false
    var body: some View {
        NavigationLink {
            List {
                Section {
                    Toggle(isOn: $モデル.セリフ体) {
                        Label("セリフ体", systemImage: "paintbrush.pointed")
                            .font(.system(.body, design: .serif))
                    }
                    Toggle(isOn: $モデル.太字) {
                        Label("太字", systemImage: "bold")
                            .font(.body.bold())
                    }
                    self.サイズピッカー()
                    Toggle(isOn: $モデル.english表記) {
                        Label("English表記", systemImage: "p.circle")
                    }
                    Toggle(isOn: $モデル.直近操作強調表示機能オフ) {
                        Label("操作した直後の駒の強調表示を常に無効",
                              systemImage: "square.slash")
                    }
                    Toggle(isOn: self.$効果音無効化) {
                        Label("効果音を無効", systemImage: "speaker.slash")
                    }
                } header: {
                    if self.groupStateObserver.isEligibleForGroupSession {
                        Text("オプション(共有相手との同期なし)")
                    } else {
                        Text("オプション")
                    }
                }
            }
            .animation(.default, value: モデル.サイズ)
            .navigationTitle("更にカスタマイズ")
        } label: {
            Label("更にカスタマイズ", systemImage: "paintpalette")
        }
    }
    private func サイズピッカー() -> some View {
        Picker(selection: $モデル.サイズ) {
            ForEach(字体.サイズ.allCases) { Text($0.ローカライズキー) }
        } label: {
            Label("駒のサイズ", systemImage: "magnifyingglass")
                .font({
                    switch モデル.サイズ {
                        case .小: .caption
                        case .標準: .body
                        case .大: .title
                        case .最大: .largeTitle
                    }
                }())
                .animation(.default, value: モデル.サイズ)
        }
    }
}
