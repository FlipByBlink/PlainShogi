import SwiftUI
import GroupActivities
import UniformTypeIdentifiers

struct 🛠ツールボタン: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Group {
                    if 📱.増減モード中 {
                        🪄増減モード完了ボタン()
                    } else {
                        メニューボタン()
                    }
                }
                .animation(.default, value: 📱.増減モード中)
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
                不具合フィードバックリンク()
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
            増減モード開始ボタン()
            一手戻すボタン()
            self.上下反転ボタン()
            self.履歴ボタン()
            self.ブックマーク表示ボタン()
            self.駒の選択解除ボタン()
        } label: {
            Image(systemName: self.セリフ体 ? "gear" : "gearshape")
                .font(.title2.weight(.light))
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
        @AppStorage("サイズ") private var サイズ: 🔠文字.サイズ = .標準
        @StateObject private var ⓖroupStateObserver = GroupStateObserver()
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
                    Toggle(isOn: $📱.🚩English表記) {
                        Label("English表記", systemImage: "p.circle")
                    }
                    Toggle(isOn: $📱.🚩直近操作強調表示機能オフ) {
                        Label("操作した直後の駒の強調表示を常に無効",
                              systemImage: "square.slash")
                    }
                } header: {
                    if self.ⓖroupStateObserver.isEligibleForGroupSession {
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
                ForEach(🔠文字.サイズ.allCases) { Text($0.ローカライズキー) }
            } label: {
                Label("駒のサイズ", systemImage: "magnifyingglass")
                    .font({
                        switch self.サイズ {
                            case .小: return .caption
                            case .標準: return .body
                            case .大: return .title
                            case .最大: return .largeTitle
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
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        NavigationLink {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(📱.現在の盤面をテキストに変換する())
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
    private struct コピーボタン: View {
        @EnvironmentObject private var 📱: 📱アプリモデル
        @State private var 完了: Bool = false
        var body: some View {
            HStack {
                Spacer()
                if self.完了 { Image(systemName: "checkmark") }
                Button {
                    📱.現在の局面をテキストとしてコピー()
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

private struct 不具合フィードバックリンク: View {
    var body: some View {
        NavigationLink {
            Self.メニュー()
        } label: {
            Label("不具合フィードバック", systemImage: "ladybug")
        }
    }
    private struct メニュー: View {
        @Environment(\.locale) private var locale
        private var 日本語環境: Bool { self.locale.languageCode == "ja" }
        private static var アドレス: String = "sear_pandora_0x@icloud.com"
        private var ボタンURL: URL {
            var 値 = "mailto:" + Self.アドレス
            let タイトル: String
            if self.日本語環境 {
                タイトル = "☖ Plain将棋盤 不具合フィードバック 🐞"
            } else {
                タイトル = "☖ PlainShogiBoard bug feedback 🐞"
            }
            値 += "?subject="
            値 += タイトル.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            if self.日本語環境 {
                値 += "&body="
                値 += "ここに入力してください".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            } else {
                値 += "&body=Input%20here"
            }
            return URL(string: 値)!
        }
        var body: some View {
            List {
                Section {
                    Label("もし、このアプリでバグやクラッシュが発生した場合、以下のボタン(もしくはアドレス)からフィードバックを送るとアプリの改善に繋がります",
                          systemImage: "ladybug")
                    Label("特にSharePlay中に発生した不具合について報告していただけるととても助かります",
                          systemImage: "shareplay")
                }
                Link(destination: self.ボタンURL) {
                    Label("メールアプリからフィードバックを送る", systemImage: "envelope")
                }
                .badge(Text(Image(systemName: "arrow.up.forward.app")))
                HStack {
                    Label(Self.アドレス, systemImage: "link")
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("コピー") {
                        UIPasteboard.general.string = Self.アドレス
                        💥フィードバック.軽め()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("不具合フィードバック")
        }
    }
}
