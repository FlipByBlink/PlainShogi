import SwiftUI
import GroupActivities

struct 🛠メニューボタン: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    var body: some View {
        if 📱.🚩駒を整理中 {
            整理完了ボタン()
        } else {
            Menu {
                🛠盤面初期化ボタン()
                🛠盤面整理開始ボタン()
                🛠移動直後強調表示クリアボタン()
                self.上下反転ボタン()
            } label: {
                Text("…")
                    .dynamicTypeSize(...DynamicTypeSize.accessibility3)
                    .padding()
            } primaryAction: {
                📱.🚩メニューを表示 = true
                振動フィードバック()
            }
            .padding()
            .tint(.primary)
            .accessibilityLabel("Open menu")
        }
    }
    func 上下反転ボタン() -> some View {
        Button {
            withAnimation { 📱.🚩上下反転.toggle() }
        } label: {
            Label(📱.🚩上下反転 ? "上下反転を元に戻す" : "上下反転させる", systemImage: "arrow.up.arrow.down")
        }
    }
}

struct 🛠アプリメニュー: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    var body: some View {
        NavigationView {
            List {
                Section {
                    Label("長押しして駒を持ち上げ、そのままスライドして移動させる", systemImage: "hand.draw")
                        .padding(.vertical, 8)
                } header: {
                    Text("あそび方")
                }
                .foregroundStyle(.primary)
                Section {
                    🛠盤面初期化ボタン()
                    🛠盤面整理開始ボタン()
                    🛠移動直後強調表示クリアボタン()
                }
                Section {
                    Toggle(isOn: $📱.🚩上下反転) {
                        Label("上下反転", systemImage: "arrow.up.arrow.down")
                    }
                    Toggle(isOn: $📱.🚩English表記) {
                        Label("English表記", systemImage: "p.circle")
                    }
                    Toggle(isOn: $📱.🚩移動直後強調表示機能オフ) {
                        Label("移動直後の強調表示機能を無効にする", systemImage: "square.slash")
                    }
                } header: {
                    Text("オプション")
                }
                Section { 履歴リンク() }
                細かな使い方リンク()
                テキスト書き出し読み込み紹介リンク()
                📣ADMenuLink()
                📄InformationMenuLink()
            }
            .navigationTitle("メニュー")
            .toolbar { 閉じるボタン() }
        }
        .onDisappear { 📱.🚩メニューを表示 = false }
    }
    func 閉じるボタン() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                📱.🚩メニューを表示 = false
                振動フィードバック()
            } label: {
                Image(systemName: "chevron.down")
                    .foregroundStyle(.secondary)
                    .grayscale(1.0)
                    .padding(8)
            }
            .accessibilityLabel("Dismiss")
        }
    }
}

struct 細かな使い方リンク: View {
    var body: some View {
        NavigationLink {
            List {
                Label("ダブルタップで盤上の駒を裏返す", systemImage: "rotate.right")
                    .padding(8)
                Section {
                    VStack {
                        Text("メニューボタンを長押しすると「初期化ボタン」や「整理ボタン」を呼び出せます。")
                            .minimumScaleFactor(0.1)
                        Image("MenuLongPress")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 160)
                            .border(.primary)
                            .padding(8)
                    }
                    .padding()
                }
                Section {
                    VStack {
                        Text("Dynamic Type に対応しているので、OSの設定に合わせて駒の字の大きさを変えたり太文字にしたりできます。")
                        Image("DynamicType")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 120)
                            .border(.primary)
                            .padding(8)
                    }
                    .padding()
                }
            }
            .navigationTitle("細かな使い方")
        } label: {
            Label("細かな使い方", systemImage: "magazine")
        }
    }
}

struct テキスト書き出し読み込み紹介リンク: View {
    @EnvironmentObject var 📱: 📱アプリモデル
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

struct テキスト変換プレビュー: View {
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
        .onReceive(🕒timer) { _ in
            if self.表示中の画像 == self.枚数 - 1 {
                self.表示中の画像 = 0
            } else {
                self.表示中の画像 += 1
            }
        }
        .animation(.default.speed(0.5), value: self.表示中の画像)
        .padding(8)
    }
}
