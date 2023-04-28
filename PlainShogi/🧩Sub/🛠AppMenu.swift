import SwiftUI
import GroupActivities

struct 🛠メニューシート: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $📱.🚩メニューを表示) {
                メニューシートコンテンツ()
                    .environmentObject(📱)
            }
    }
}

struct 🛠非SharePlay時のメニューボタン: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var 縦並び: Bool {
        self.verticalSizeClass == .regular
        && self.horizontalSizeClass == .compact
    }
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    func body(content: Content) -> some View {
        content
            .overlay(alignment: self.縦並び ? .bottomTrailing : .topTrailing) {
                if !self.ⓖroupStateObserver.isEligibleForGroupSession {
                    メニューボタン()
                        .padding()
                }
            }
    }
}

struct 🛠SharePlayインジケーターやメニューボタン: View {
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        if self.ⓖroupStateObserver.isEligibleForGroupSession {
            HStack {
                👥SharePlayインジケーター()
                    .padding(.leading, 12)
                Spacer()
                メニューボタン()
            }
        }
    }
}

private struct メニューボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    var body: some View {
        if 📱.編集状態 != nil {
            🪄編集完了ボタン()
        } else {
            Menu {
                強調表示クリアボタン()
                盤面初期化ボタン()
                編集モード開始ボタン(タイトル: "編集モード")
                一手戻すボタン()
                self.上下反転ボタン()
                self.履歴ボタン()
                self.ブックマーク保存ボタン()
                self.ブックマーク復元ボタン()
            } label: {
                Image(systemName: self.セリフ体 ? "gear" : "gearshape")
                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                    .padding(2)
                    .background {
                        Circle()
                            .foregroundStyle(.background)
                            .opacity(0.8)
                    }
                    .padding(8)
            } primaryAction: {
                📱.🚩メニューを表示 = true
                💥フィードバック.軽め()
            }
            .tint(.primary)
            .accessibilityLabel("Open menu")
            .sheet(isPresented: $📱.🚩履歴を表示) { self.履歴単体メニュー() }
        }
    }
    private func 上下反転ボタン() -> some View {
        Button {
            withAnimation { 📱.🚩上下反転.toggle() }
            💥フィードバック.成功()
        } label: {
            Label(📱.🚩上下反転 ? "上下反転を元に戻す" : "上下反転させる",
                  systemImage: "arrow.up.arrow.down")
        }
    }
    private func 履歴ボタン() -> some View {
        Button {
            📱.🚩履歴を表示 = true
            💥フィードバック.軽め()
        } label: {
            Label("履歴を表示", systemImage: "clock")
        }
    }
    private func 履歴単体メニュー() -> some View {
        NavigationView {
            📜履歴メニュー()
                .toolbar {
                    Button {
                        📱.🚩履歴を表示 = false
                        💥フィードバック.軽め()
                    } label: {
                        Image(systemName: "chevron.down")
                            .grayscale(1.0)
                    }
                }
        }
        .navigationViewStyle(.stack)
        .environmentObject(📱)
    }
    private func ブックマーク保存ボタン() -> some View {
        Button {
            📱.現在の局面をブックマークする()
        } label: {
            Label("この局面をブックマーク", systemImage: "bookmark")
        }
    }
    private func ブックマーク復元ボタン() -> some View {
        Button {
            guard let 局面 = 局面モデル.ブックマーク else { return }
            📱.任意の局面を現在の局面として適用する(局面)
        } label: {
            Label("ブックマークから復元", systemImage: "square.and.arrow.down")
            
                .font(.body.weight(.medium))
                .buttonStyle(.bordered)
        }
    }
}

private struct メニューシートコンテンツ: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack { self.ⓒontent() }
            } else {
                NavigationView { self.ⓒontent() }
                    .navigationViewStyle(.stack)
            }
        }
        //.onDisappear { 📱.🚩メニューを表示 = false } //TODO: 再検討
    }
    private func ⓒontent() -> some View {
        List {
            Self.SharePlay誘導セクション()
            Section {
                盤面初期化ボタン()
                一手戻すボタン()
                編集モード開始ボタン(タイトル: "駒を消したり増やしたりする")
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
        .toolbar { self.閉じるボタン() }
    }
    private func 閉じるボタン() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                📱.🚩メニューを表示 = false
                💥フィードバック.軽め()
            } label: {
                Image(systemName: "chevron.down")
                    .grayscale(1.0)
            }
            .accessibilityLabel("Dismiss")
        }
    }
    private struct SharePlay誘導セクション: View {
        @EnvironmentObject var 📱: 📱アプリモデル
        @StateObject private var ⓖroupStateObserver = GroupStateObserver()
        var body: some View {
            if self.ⓖroupStateObserver.isEligibleForGroupSession {
                Section {
                    NavigationLink {
                        👥SharePlayガイド($📱.🚩メニューを表示)
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
}

private struct 盤面初期化ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.盤面を初期化する() }
            📱.🚩メニューを表示 = false
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
    var タイトル: LocalizedStringKey
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.編集状態 = .盤面を編集中 }
            📱.🚩メニューを表示 = false
            💥フィードバック.軽め()
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
        @AppStorage("サイズ") private var サイズ: フォント.サイズ = .標準
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
                        ForEach(フォント.サイズ.allCases) { Text($0.rawValue) }
                    } label: {
                        Label("駒のサイズ", systemImage: "magnifyingglass")
                            .font(self.サイズ.ピッカーフォント)
                            .animation(.default, value: self.サイズ)
                    }
                    Toggle(isOn: $📱.🚩English表記) {
                        Label("English表記", systemImage: "p.circle")
                    }
                } header: {
                    Text("オプション")
                }
                Section {
                    強調表示クリアボタン()
                    Toggle(isOn: $📱.🚩直近操作強調表示機能オフ) {
                        Label("操作した直後の駒を強調表示する機能を常に無効にする",
                              systemImage: "square.slash")
                    }
                } header: {
                    Text("強調表示")
                }
            }
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
                //Label("ダブルタップで盤上の駒を裏返す", systemImage: "rotate.right")
                //    .padding(8)
                self.メニューショートカットセクション()
                //self.DynamicTypeセクション()
            }
            .navigationTitle("細かな使い方")
        } label: {
            Label("細かな使い方", systemImage: "magazine")
        }
    }
    private func メニューショートカットセクション() -> some View {
        Section {
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
        }
    }
    //private func DynamicTypeセクション() -> some View {
    //    Section {
    //        VStack {
    //            Text("Dynamic Type に対応しているので、OSの設定に合わせて駒の字の大きさを変えたり太文字にしたりできます。")
    //            Image("DynamicType")
    //                .resizable()
    //                .scaledToFit()
    //                .frame(maxHeight: 120)
    //                .border(.black)
    //                .padding(8)
    //        }
    //        .padding()
    //        VStack {
    //            Text("「アクセシビリティ/Appごとの設定」にて本アプリのみを対象に設定を変更することもできます。")
    //            Image(systemName: "photo")
    //                .resizable()
    //                .scaledToFit()
    //                .frame(maxHeight: 120)
    //                .border(.black)
    //                .padding(8)
    //        }
    //        .padding()
    //    }
    //}
}

private struct テキスト書き出し読み込み紹介リンク: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        NavigationLink {
            List {
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
                    Text(📱.現在の盤面をテキストに変換する())
                        .padding()
                        .accessibilityLabel("テキスト")
                        .textSelection(.enabled)
                } header: {
                    Text("テキスト書き出し例")
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
