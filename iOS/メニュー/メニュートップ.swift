import SwiftUI
import GroupActivities
import UniformTypeIdentifiers

struct メニュートップ: View {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        List {
            SharePlay誘導セクション()
            Section {
                盤面初期化ボタン()
                一手戻すボタン()
                増減モード開始ボタン(タイトル: "駒を消したり増やしたりする")
                強調表示クリアボタン()
            } header: {
                Text("編集")
            }
            Section {
                Toggle(isOn: $モデル.上下反転) {
                    Label("上下反転", systemImage: "arrow.up.arrow.down")
                }
                見た目カスタマイズメニューリンク()
            } header: {
                if self.groupStateObserver.isEligibleForGroupSession {
                    Text("オプション(共有相手との同期なし)")
                } else {
                    Text("オプション")
                }
            }
            Section {
                NavigationLink {
                    ブックマークメニュー()
                } label: {
                    Label("ブックマーク", systemImage: "bookmark")
                }
                NavigationLink {
                    履歴メニュー()
                } label: {
                    Label("履歴", systemImage: "clock")
                }
                .disabled(局面モデル.履歴.isEmpty)
            }
            Section {
                SharePlay紹介メニューリンク()
                細かな使い方リンク()
                テキスト書き出し読み込み紹介リンク()
                不具合フィードバックリンク()
            }
            Section {
                ℹ️IconAndName()
                ℹ️AppStoreLink()
                NavigationLink {
                    List { ℹ️AboutAppContent() }
                        .navigationTitle(String(localized: "About App", table: "🌐AboutApp"))
                } label: {
                    Label(String(localized: "About App", table: "🌐AboutApp"),
                          systemImage: "doc")
                }
            }
            🛒InAppPurchaseMenuLink()
        }
        .navigationTitle("メニュー")
        .animation(.default, value: self.groupStateObserver.isEligibleForGroupSession)
    }
}

private struct SharePlay誘導セクション: View {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        if self.groupStateObserver.isEligibleForGroupSession {
            Section {
                NavigationLink {
                    SharePlayガイドメニュー()
                } label: {
                    Label("アクティビティ", systemImage: "shareplay")
                        .badge("共有将棋盤")
                }
            } header: {
                Text("SharePlay")
                    .textCase(.none)
            }
        }
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
        @EnvironmentObject var モデル: アプリモデル
        @AppStorage("セリフ体") var セリフ体: Bool = false
        @AppStorage("太字") var 太字: Bool = false
        @AppStorage("サイズ") var サイズ: 字体.サイズ = .標準
        @StateObject private var groupStateObserver = GroupStateObserver()
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
}

private struct 細かな使い方リンク: View {
    var body: some View {
        NavigationLink {
            List {
                Label("長押しして駒を持ち上げ、そのままスライドして移動させる",
                      systemImage: "hand.draw")
                Section {
                    Label("iCloudによって端末間でデータ(局面/履歴/ブックマーク)が同期されます",
                          systemImage: "icloud")
                } footer: {
                    Text("iCloud同期は簡易的な用途を想定しています。「同時に起動している端末間での同期」といったリアルタイム性の高い用途は想定していません。")
                }
                self.メニューショートカットセクション()
            }
            .navigationTitle("細かな使い方")
        } label: {
            Label("細かな使い方", systemImage: "magazine")
        }
    }
    private func メニューショートカットセクション() -> some View {
        Section {
#if !targetEnvironment(macCatalyst)
            VStack {
                Label("メニューボタンを長押しすると「初期化ボタン」や「一手戻すボタン」などを呼び出せます",
                      systemImage: "gearshape")
                Image("MenuLongPress")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .border(.black)
                    .padding(8)
            }
            .padding(.vertical, 8)
#endif
        }
    }
}

private struct テキスト書き出し読み込み紹介リンク: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        NavigationLink {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(モデル.現在の盤面をテキストに変換する())
                            .textSelection(.enabled)
                        Self.コピーボタン()
                    }
                    .padding()
                } header: {
                    Text("テキスト書き出し例")
                }
                Section {
                    VStack(alignment: .leading, spacing: 2) {
                        Label("駒を他のアプリへドラッグして盤面をテキストとして書き出せます。",
                              systemImage: "square.and.arrow.up")
                        テキスト変換プレビュー(フォルダー名: "TextExport", 枚数: 4)
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    VStack(alignment: .leading, spacing: 2) {
                        Label("他のアプリからテキストを盤上にドロップして盤面を読み込めます。「☗」が先頭のテキストをドロップしてください。",
                              systemImage: "square.and.arrow.down")
                        テキスト変換プレビュー(フォルダー名: "TextImport", 枚数: 5)
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    Button {
                        モデル.テキストを局面としてペースト()
                        モデル.表示中のシート = nil
                    } label: {
                        Label("テキストを局面としてペースト", systemImage: "doc.on.clipboard")
                    }
                }
            }
            .navigationTitle("テキスト機能")
        } label: {
            Label("テキスト書き出し/読み込み機能", systemImage: "square.and.arrow.up.on.square")
        }
    }
    private struct コピーボタン: View {
        @EnvironmentObject var モデル: アプリモデル
        @State private var 完了: Bool = false
        var body: some View {
            HStack {
                Spacer()
                if self.完了 { Image(systemName: "checkmark") }
                Button {
                    モデル.現在の局面をテキストとしてコピー()
                    withAnimation { self.完了 = true }
                } label: {
                    Label("テキストとしてコピー", systemImage: "doc.on.doc")
                        .foregroundStyle(self.完了 ? .secondary : .primary)
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

private struct テキスト変換プレビュー: View {
    var フォルダー名: String
    var 枚数: Int
    private let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
    @State private var 表示中の画像: Int = 0
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                ForEach( 0 ..< self.枚数, id: \.self) { 番号 in
                    if 番号 <= self.表示中の画像 {
                        Image(self.フォルダー名 + "/" + 番号.description)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            ProgressView(value: Double(self.表示中の画像), total: Double(self.枚数 - 1))
                .grayscale(1)
                .padding(.horizontal)
                .accessibilityHidden(true)
        }
        .onReceive(self.timer) { _ in
            withAnimation(.default.speed(0.5)) {
                if self.表示中の画像 == self.枚数 - 1 {
                    self.表示中の画像 = 0
                } else {
                    self.表示中の画像 += 1
                }
            }
        }
        .padding(8)
    }
}
