import SwiftUI
import GroupActivities
import UniformTypeIdentifiers

struct 🛠ツールボタン: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Group {
                    if 📱.編集中 {
                        🪄編集完了ボタン()
                    } else {
                        メニューボタン()
                    }
                }
                .animation(.default, value: 📱.編集中)
            }
    }
}

struct 🛠アプリメニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        List {
            SharePlay誘導セクション()
            Section {
                盤面初期化ボタン()
                一手戻すボタン()
                編集モード開始ボタン(タイトル: "駒を消したり増やしたりする")
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
                if self.ⓖroupStateObserver.isEligibleForGroupSession {
                    Text("オプション(共有相手との同期なし)")
                } else {
                    Text("オプション")
                }
            }
            📜履歴類セクション()
            Section {
                👥SharePlay紹介リンク()
                細かな使い方リンク()
                テキスト書き出し読み込み紹介リンク()
            }
            📣ADMenuLink()
            ℹ️AboutAppLink()
        }
        .navigationTitle("メニュー")
        .animation(.default, value: self.ⓖroupStateObserver.isEligibleForGroupSession)
    }
}

private struct メニューボタン: View { // ⚙️
    @EnvironmentObject private var 📱: 📱アプリモデル
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    var body: some View {
#if !targetEnvironment(macCatalyst)
        self.ⓒontent()
#else
        EmptyView()
#endif
    }
    private func ⓒontent() -> some View {
        Menu {
            強調表示クリアボタン()
            盤面初期化ボタン()
            編集モード開始ボタン()
            一手戻すボタン()
            self.上下反転ボタン()
            self.履歴ボタン()
            self.ブックマーク表示ボタン()
            self.駒の選択解除ボタン()
        } label: {
            Image(systemName: self.セリフ体 ? "gear" : "gearshape")
                .font(.title2)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .padding()
                .padding(.trailing, 8)
        } primaryAction: {
            📱.シートを表示 = .メニュー
        }
        .tint(.primary)
        .accessibilityLabel("Open menu")
    }
    private func 上下反転ボタン() -> some View {
        Button {
            📱.🚩上下反転.toggle()
            💥フィードバック.成功()
        } label: {
            Label(📱.🚩上下反転 ? "上下反転を元に戻す" : "上下反転させる",
                  systemImage: "arrow.up.arrow.down")
        }
    }
    private func 履歴ボタン() -> some View {
        Button {
            📱.シートを表示 = .履歴
        } label: {
            Label("履歴を表示", systemImage: "clock")
        }
    }
    private func ブックマーク表示ボタン() -> some View {
        Button {
            📱.シートを表示 = .ブックマーク
        } label: {
            Label("ブックマークを表示", systemImage: "bookmark")
        }
    }
    private func 駒の選択解除ボタン() -> some View {
        Group {
            if 📱.選択中の駒 != .なし {
                Button {
                    📱.駒の選択を解除する()
                } label: {
                    Label("駒の選択を解除", systemImage: "square.slash")
                }
            }
        }
    }
}

private struct SharePlay誘導セクション: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        if self.ⓖroupStateObserver.isEligibleForGroupSession {
            Section {
                NavigationLink {
                    👥SharePlayガイド()
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
    private var 何も強調表示されていない: Bool {
        📱.局面.直近の操作 == .なし && 📱.選択中の駒 == .なし
    }
    var body: some View {
        Button {
            📱.強調表示をクリア()
        } label: {
            Label("強調表示をクリア", systemImage: "square.dashed")
        }
        .disabled(self.何も強調表示されていない)
        .disabled(📱.🚩直近操作強調表示機能オフ && (📱.選択中の駒 == .なし))
    }
}

private struct 編集モード開始ボタン: View {
    var タイトル: LocalizedStringKey = "編集モード"
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            📱.編集モードを開始する()
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
                    Picker(selection: self.$サイズ) {
                        ForEach(🔠フォント.サイズ.allCases) { Text($0.ローカライズキー) }
                    } label: {
                        Label("駒のサイズ", systemImage: "magnifyingglass")
                            .font(self.サイズ.ピッカーフォント)
                    }
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

private struct 細かな使い方リンク: View {
    var body: some View {
        NavigationLink {
            List {
                Label("長押しして駒を持ち上げ、そのままスライドして移動させる",
                      systemImage: "hand.draw")
                .padding(.vertical, 8)
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
                Text("メニューボタンを長押しすると「初期化ボタン」や「編集ボタン」を呼び出せます。")
                    .minimumScaleFactor(0.1)
                Image("MenuLongPress")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 160)
                    .border(.black)
                    .padding(8)
            }
            .padding()
#endif
        }
    }
}

private struct テキスト書き出し読み込み紹介リンク: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        NavigationLink {
            List {
                Section {
                    HStack(alignment: .bottom) {
                        Text(📱.現在の盤面をテキストに変換する())
                            .textSelection(.enabled)
                        Spacer()
                        Button {
                            📱.現在の局面をテキストとしてコピー()
                        } label: {
                            Label("コピー", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } header: {
                    Text("テキスト書き出し例")
                }
                Section {
                    Label("駒を他のアプリへドラッグして盤面をテキストとして書き出せます。",
                          systemImage: "square.and.arrow.up")
                    テキスト変換プレビュー(フォルダー名: "TextExport", 枚数: 4)
                }
                .listRowSeparator(.hidden)
                Section {
                    Label("他のアプリからテキストを盤上にドロップして盤面を読み込めます。「☗」が先頭のテキストをドロップしてください。",
                          systemImage: "square.and.arrow.down")
                    テキスト変換プレビュー(フォルダー名: "TextImport", 枚数: 5)
                }
                .listRowSeparator(.hidden)
                Section {
                    Button {
                        📱.テキストを局面としてペースト()
                        📱.シートを表示 = nil
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
}

private struct テキスト変換プレビュー: View {
    var フォルダー名: String
    var 枚数: Int
    private let 🕒timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
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
        .onReceive(self.🕒timer) { _ in
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
