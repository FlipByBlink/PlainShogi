import SwiftUI

struct メニューボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        if !📱.増減モード中 {
            VStack {
                Spacer()
                Button {
                    self.📱.シートを表示 = .メニュー
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title3)
                        .padding(8)
                }
                .buttonStyle(.plain)
                .padding(.bottom)
            }
            .focusSection()
        }
    }
}

struct メニューコンテンツ: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        NavigationStack {
            List {
                Section {
                    盤面初期化ボタン()
                    一手戻すボタン()
                    増減モード開始ボタン(タイトル: "駒を消したり増やしたりする")
                    強調表示クリアボタン()
                } header: {
                    Text("編集")
                }
                Section {
                    Toggle(isOn: $📱.🚩上下反転) {
                        Label("上下反転", systemImage: "arrow.up.arrow.down")
                    }
                    見た目カスタマイズメニューリンク()
                } header: {
                    Text("オプション")
                }
            }
            .navigationTitle("メニュー")
        }
    }
}

private struct 盤面初期化ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            📱.盤面を初期化する()
        } label: {
            Label("盤面を初期化", systemImage: "arrow.counterclockwise")
        }
    }
}

private struct 強調表示クリアボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            📱.強調表示をクリア()
        } label: {
            Label("強調表示をクリア", systemImage: "square.dashed")
        }
        .disabled(📱.何も強調表示されていない)
        .disabled(📱.強調表示常時オフかつ駒が選択されていない)
    }
}

private struct 増減モード開始ボタン: View {
    var タイトル: LocalizedStringKey = "駒を増減"
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            📱.増減モードを開始する()
        } label: {
            Label(self.タイトル, systemImage: "wand.and.rays")
        }
    }
}

private struct 一手戻すボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            📱.一手戻す()
        } label: {
            Label("一手だけ戻す", systemImage: "arrow.backward.to.line")
        }
        .disabled(📱.局面.一手前の局面 == nil)
    }
}

private struct 見た目カスタマイズメニューリンク: View {
    var body: some View {
        NavigationLink {
            Self.コンテンツ()
        } label: {
            Label("見た目をカスタマイズ", systemImage: "paintpalette")
        }
    }
    private struct コンテンツ: View {
        @EnvironmentObject private var 📱: 📱アプリモデル
        @AppStorage("セリフ体") private var セリフ体: Bool = false
        @AppStorage("太字") private var 太字: Bool = false
        @AppStorage("サイズ") private var サイズ: 🔠フォント.サイズ = .標準
        var body: some View {
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
                    フォントサイズピッカー()
                    Toggle(isOn: $📱.🚩English表記) {
                        Label("English表記", systemImage: "p.circle")
                    }
                    Toggle(isOn: $📱.🚩直近操作強調表示機能オフ) {
                        Label("操作した直後の駒の強調表示を常に無効",
                              systemImage: "square.slash")
                    }
                } header: {
                    Text("オプション")
                }
            }
            .animation(.default, value: self.サイズ)
            .navigationTitle("見た目をカスタマイズ")
        }
    }
}

private struct フォントサイズピッカー: View {
    @AppStorage("サイズ") private var サイズ: 🔠フォント.サイズ = .標準
    var body: some View {
        Picker(selection: self.$サイズ) {
            ForEach(🔠フォント.サイズ.allCases) { Text($0.ローカライズキー) }
        } label: {
            Label("駒のサイズ", systemImage: "magnifyingglass")
                .font({
                    switch self.サイズ {
                        case .小: return .caption
                        case .標準: return .body
                        case .大: return .title3
                        case .最大: return .title2
                    }
                }())
        }
        .pickerStyle(.navigationLink)
    }
}
