import SwiftUI
import GroupActivities

private struct メニューボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        if 📱.🚩駒を整理中 {
            整理完了ボタン()
        } else {
            Menu {
                直近操作強調表示クリアボタン()
                盤面初期化ボタン()
                盤面整理開始ボタン()
                一手戻すボタン()
                self.上下反転ボタン()
                self.履歴ボタン()
            } label: {
                Image(systemName: "gearshape")
                    .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                    .padding(2)
                    .background {
                        Circle()
                            .foregroundStyle(.background)
                            .opacity(0.8)
                    }
                    .padding(8)
            } primaryAction: {
                📱.🚩メニューを表示 = true
                振動フィードバック()
            }
            .tint(.primary)
            .accessibilityLabel("Open menu")
            .sheet(isPresented: $📱.🚩履歴を表示) { self.履歴単体メニュー() }
        }
    }
    private func 上下反転ボタン() -> some View {
        Button {
            withAnimation { 📱.🚩上下反転.toggle() }
        } label: {
            Label(📱.🚩上下反転 ? "上下反転を元に戻す" : "上下反転させる", systemImage: "arrow.up.arrow.down")
        }
    }
    private func 履歴ボタン() -> some View {
        Button {
            📱.🚩履歴を表示 = true
        } label: {
            Label("履歴", systemImage: "clock")
        }
    }
    private func 履歴単体メニュー() -> some View {
        NavigationView {
            履歴List()
                .toolbar {
                    Button {
                        📱.🚩履歴を表示 = false
                        振動フィードバック()
                    } label: {
                        Image(systemName: "chevron.down")
                            .grayscale(1.0)
                    }
                }
        }
        .navigationViewStyle(.stack)
        .environmentObject(📱)
    }
}

struct 🛠非SharePlay時のメニューボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        if !self.ⓖroupStateObserver.isEligibleForGroupSession {
            メニューボタン()
                .padding()
        }
    }
}

struct 🛠SharePlayインジケーターやメニューボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        if self.ⓖroupStateObserver.isEligibleForGroupSession {
            HStack {
                SharePlayインジケーター()
                    .padding(.leading, 12)
                Spacer()
                メニューボタン()
            }
        }
    }
}

struct 🛠アプリメニュー: View {
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
            self.あそび方セクション()
            Section { 履歴リンク() }
            Section {
                盤面初期化ボタン()
                盤面整理開始ボタン()
                一手戻すボタン()
                直近操作強調表示クリアボタン()
            }
            Section {
                Toggle(isOn: $📱.🚩上下反転) {
                    Label("上下反転", systemImage: "arrow.up.arrow.down")
                }
                Toggle(isOn: $📱.🚩English表記) {
                    Label("English表記", systemImage: "p.circle")
                }
                Toggle(isOn: $📱.🚩直近操作強調表示機能オフ) {
                    Label("操作した直後の駒を強調表示する機能を無効にする", systemImage: "square.slash")
                }
            } header: {
                if self.ⓖroupStateObserver.isEligibleForGroupSession {
                    Text("オプション(共有相手との同期なし)")
                } else {
                    Text("オプション")
                }
            }
            Section {
                SharePlay紹介リンク()
                細かな使い方リンク()
                テキスト書き出し読み込み紹介リンク()
            }
            📣ADMenuLink()
            ℹ️AboutAppLink()
        }
        .navigationTitle("メニュー")
        .toolbar { self.閉じるボタン() }
    }
    private func あそび方セクション() -> some View {
        Section {
            Label("長押しして駒を持ち上げ、そのままスライドして移動させる", systemImage: "hand.draw")
                .padding(.vertical, 8)
        } header: {
            Text("あそび方")
        }
        .foregroundStyle(.primary)
    }
    private func 閉じるボタン() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                📱.🚩メニューを表示 = false
                振動フィードバック()
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
                        SharePlayガイド($📱.🚩メニューを表示)
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

private struct 直近操作強調表示クリアボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.直近操作の強調表示をクリア() }
        } label: {
            Label("操作直後の強調表示をクリア", systemImage: "square.dashed")
        }
        .disabled(📱.局面.直近の操作 == .なし)
        .disabled(📱.🚩直近操作強調表示機能オフ)
    }
}

private struct 盤面整理開始ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        Button {
            withAnimation { 📱.🚩駒を整理中 = true }
            📱.🚩メニューを表示 = false
            振動フィードバック()
        } label: {
            Label("駒を消したり増やしたりする", systemImage: "wand.and.rays")
        }
    }
}

private struct 一手戻すボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 一手前の局面: 局面モデル? {
        局面モデル.履歴.last(where: { $0.更新日時 != 📱.局面.更新日時 })
    }
    var body: some View {
        if let 一手前の局面 {
            Button {
                📱.一手戻す(一手前の局面)
            } label: {
                Label("一手だけ戻す", systemImage: "arrow.backward.to.line")
            }
        }
    }
}

private struct 細かな使い方リンク: View {
    var body: some View {
        NavigationLink {
            List {
                Label("ダブルタップで盤上の駒を裏返す", systemImage: "rotate.right")
                    .padding(8)
                self.メニューショートカットセクション()
                self.DynamicTypeセクション()
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
    private func DynamicTypeセクション() -> some View {
        Section {
            VStack {
                Text("Dynamic Type に対応しているので、OSの設定に合わせて駒の字の大きさを変えたり太文字にしたりできます。")
                Image("DynamicType")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 120)
                    .border(.black)
                    .padding(8)
            }
            .padding()
        }
    }
}

private struct テキスト書き出し読み込み紹介リンク: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        NavigationLink {
            List {
                Section {
                    Label("駒を他のアプリへドラッグして盤面をテキストとして書き出せます。", systemImage: "square.and.arrow.up")
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

private struct ℹ️AboutAppLink: View {
    var body: some View {
        Section {
            GeometryReader { 📐 in
                VStack(spacing: 12) {
                    Image("RoundedIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                    VStack(spacing: 6) {
                        Text("Plain将棋盤")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .tracking(1.5)
                            .opacity(0.75)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                        Text("App for iPhone / iPad")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                }
                .padding(20)
                .padding(.top, 8)
                .frame(width: 📐.size.width)
            }
            .frame(height: 200)
            🔗AppStoreLink()
            NavigationLink  {
                ℹ️AboutAppMenu()
            } label: {
                Label("About App", systemImage: "doc")
            }
        }
    }
}
