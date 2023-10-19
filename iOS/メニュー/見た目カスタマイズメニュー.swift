import SwiftUI
import GroupActivities

struct 見た目カスタマイズメニューリンク: View {
    @EnvironmentObject var モデル: アプリモデル
    @AppStorage("セリフ体") var セリフ体: Bool = false
    @AppStorage("太字") var 太字: Bool = false
    @AppStorage("サイズ") var サイズ: 字体.サイズ = .標準
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationLink {
            List {
                Section {
                    Toggle(isOn: self.$セリフ体) {
                        Label("セリフ体", systemImage: "paintbrush.pointed")
                            .font(.system(.body, design: .serif))
                    }
                    Toggle(isOn: self.$太字) {
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
                } header: {
                    if self.groupStateObserver.isEligibleForGroupSession {
                        Text("オプション(共有相手との同期なし)")
                    } else {
                        Text("オプション")
                    }
                }
            }
            .animation(.default, value: self.サイズ)
            .navigationTitle("見た目をカスタマイズ")
        } label: {
            Label("見た目をカスタマイズ", systemImage: "paintpalette")
        }
    }
    private func サイズピッカー() -> some View {
        Picker(selection: self.$サイズ) {
            ForEach(字体.サイズ.allCases) { Text($0.ローカライズキー) }
        } label: {
            Label("駒のサイズ", systemImage: "magnifyingglass")
                .font({
                    switch self.サイズ {
                        case .小: .caption
                        case .標準: .body
                        case .大: .title
                        case .最大: .largeTitle
                    }
                }())
                .animation(.default, value: self.サイズ)
        }
    }
}
