import SwiftUI

struct 🛠サイドバー: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
    @State private var 表示: Bool = false
    @FocusState private var 初期フォーカス: Bool
    @AppStorage("太字") private var 太字: Bool = false
    @AppStorage("ｻｲﾄﾞﾊﾞｰﾎﾞﾀﾝ非表示") private var サイドバー用ボタン常時非表示: Bool = false
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .leading) { self.サイドバー呼び出しボタン() }
            .overlay(alignment: .leading) {
                if self.表示 {
                    ZStack {
                        Rectangle()
                            .fill(.ultraThickMaterial)
                        NavigationStack {
                            self.メニュー()
                                .padding(.top, 24)
                                .padding(.trailing, 40)
                        }
                    }
                    .frame(width: 600)
                    .compositingGroup()
                    .shadow(radius: 24)
                    .ignoresSafeArea()
                    .transition(.move(edge: .leading))
                    .onChange(of: self.現在のフォーカス) {
                        if case .盤上(_) = $0 { self.表示 = false }
                    }
                }
            }
            .animation(.default, value: self.表示)
            .onExitCommand(perform: self.初期フォーカス ? nil : self.戻るアクション)
    }
    private func 戻るアクション() {
        guard !📱.増減モード中 else { 📱.増減モードを終了する(); return }
        if self.表示 == false {
            self.表示 = true
            self.初期フォーカス = true
        } else {
            self.表示 = false
        }
    }
    private func サイドバー呼び出しボタン() -> some View {
        Group {
            if !📱.増減モード中, !self.サイドバー用ボタン常時非表示 {
                VStack {
                    Button {
                        self.表示 = true
                        self.初期フォーカス = true
                    } label: {
                        Image(systemName: "gearshape")
                            .fontWeight(.light)
                            .padding()
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .focusSection()
            }
        }
    }
    private func メニュー() -> some View {
        List {
            Button {
                self.表示 = false
            } label: {
                Label("再開", systemImage: "play")
            }
            .focused(self.$初期フォーカス)
            Divider()
            Button {
                self.📱.シートを表示 = .メニュー
                self.表示 = false
            } label: {
                Label("メニューを表示", systemImage: "gearshape")
            }
            Divider()
            盤面初期化ボタン()
            一手戻すボタン()
            Toggle(isOn: $📱.🚩上下反転) {
                Label("上下反転", systemImage: "arrow.up.arrow.down")
            }
            Toggle(isOn: self.$太字) {
                Label("太字", systemImage: "bold")
            }
            Toggle(isOn: $📱.🚩English表記) {
                Label("English表記", systemImage: "p.circle")
            }
            NavigationLink {
                Self.フォントサイズピッカー(サイドバーを表示: self.$表示)
            } label: {
                Label("駒のサイズ", systemImage: "magnifyingglass")
            }
        }
    }
    private struct フォントサイズピッカー: View {
        @Environment(\.dismiss) var dismiss
        @Binding var サイドバーを表示: Bool
        @AppStorage("サイズ") private var サイズ: 🔠フォント.サイズ = .標準
        var body: some View {
            List {
                Picker(selection: self.$サイズ) {
                    ForEach(🔠フォント.サイズ.allCases) { Text($0.ローカライズキー) }
                } label: {
                    Label("駒のサイズ", systemImage: "magnifyingglass")
                }
                .pickerStyle(.inline)
            }
            .padding(.trailing, 40)
            .onExitCommand { self.dismiss() }
        }
    }
}

struct 🛠メニューコンテンツ: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        TabView {
            編集メニュー()
                .tabItem { Label("編集", systemImage: "pencil") }
            オプションメニュー()
                .tabItem { Label("オプション", systemImage: "gear") }
            履歴メニュー()
                .tabItem { Label("履歴", systemImage: "clock") }
            ブックマークメニュー()
                .tabItem { Label("ブックマーク", systemImage: "bookmark") }
            ガイドメニュー()
                .tabItem { Label("ガイド", systemImage: "doc.text") }
            アプリについてメニュー()
                .tabItem { Label("アプリについて", systemImage: "questionmark") }
        }
        .background(.background)
    }
}

private struct 編集メニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        List {
            盤面初期化ボタン()
            一手戻すボタン()
            self.増減モード開始ボタン()
            self.強調表示クリアボタン()
        }
        .padding(.top, 64)
        .padding(.horizontal, 400)
    }
    private func 増減モード開始ボタン() -> some View {
        Button {
            📱.増減モードを開始する()
        } label: {
            Label("駒を消したり増やしたりする", systemImage: "wand.and.rays")
        }
    }
    private func 強調表示クリアボタン() -> some View {
        Button {
            📱.強調表示をクリア()
        } label: {
            Label("強調表示をクリア", systemImage: "square.dashed")
        }
        .disabled(📱.何も強調表示されていない)
        .disabled(📱.強調表示常時オフかつ駒が選択されていない)
    }
}

private struct 盤面初期化ボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @State private var 初期化直後: Bool = false
    var body: some View {
        Button {
            📱.盤面を初期化する()
            self.初期化直後 = true
        } label: {
            Label("盤面を初期化", systemImage: "arrow.counterclockwise")
        }
        .disabled(self.初期化直後)
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

private struct オプションメニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @AppStorage("太字") private var 太字: Bool = false
    @AppStorage("サイズ") private var サイズ: 🔠フォント.サイズ = .標準
    @AppStorage("ｻｲﾄﾞﾊﾞｰﾎﾞﾀﾝ非表示") private var サイドバー用ボタン常時非表示: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Toggle(isOn: $📱.🚩上下反転) {
                    Label("上下反転", systemImage: "arrow.up.arrow.down")
                }
                Toggle(isOn: self.$太字) {
                    Label("太字", systemImage: "bold")
                }
                Picker(selection: self.$サイズ) {
                    ForEach(🔠フォント.サイズ.allCases) { Text($0.ローカライズキー) }
                } label: {
                    Label("駒のサイズ", systemImage: "magnifyingglass")
                }
                .pickerStyle(.navigationLink)
                Toggle(isOn: $📱.🚩English表記) {
                    Label("English表記", systemImage: "p.circle")
                }
                Toggle(isOn: $📱.🚩直近操作強調表示機能オフ) {
                    Label("操作した直後の駒の強調表示を常に無効",
                          systemImage: "square.slash")
                }
                VStack(alignment: .leading, spacing: 6) {
                    Toggle(isOn: self.$サイドバー用ボタン常時非表示) {
                        Label("サイドバー呼び出しボタンを常に非表示",
                              systemImage: "gear.badge.xmark")
                    }
                    Text("戻るボタンを押すとサイドバーを表示できます")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.top, 64)
            .padding(.horizontal, 400)
        }
    }
}

private struct 履歴メニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        List {
            ForEach(局面モデル.履歴.reversed(), id: \.更新日時) { 局面 in
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 6) {
                        Text(局面.更新日付表記)
                        Text(局面.更新時刻表記)
                            .font(.subheadline)
                    }
                    局面プレビュー(局面)
                        .padding(.vertical)
                        .padding(.horizontal, 64)
                    Button {
                        📱.任意の局面を現在の局面として適用する(局面)
                    } label: {
                        Label("復元", systemImage: "square.and.arrow.down")
                            .padding()
                    }
                    .font(.caption.weight(.medium))
                    .buttonStyle(.card)
                    .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.vertical)
                .padding(.top, 局面.更新日時 == 局面モデル.履歴.last?.更新日時 ? 120 : 0)
            }
            Section {
                Text("直近の約30局面を履歴として保存します")
                    .foregroundStyle(.secondary)
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .focusable()
            }
        }
    }
}

private struct ブックマークメニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @State private var ブックマーク: 局面モデル? = nil
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 24) {
                if let ブックマーク {
                    局面プレビュー(ブックマーク)
                } else {
                    局面プレビュー(.初期セット)
                        .opacity(0.4)
                }
                Button {
                    guard let ブックマーク else { return }
                    📱.任意の局面を現在の局面として適用する(ブックマーク)
                } label: {
                    Label("復元", systemImage: "square.and.arrow.down")
                        .font(.caption.weight(.medium))
                        .strikethrough(self.ブックマーク == nil)
                        .padding()
                }
                .buttonStyle(.card)
                .foregroundStyle(.secondary)
                .disabled(self.ブックマーク == nil)
            }
            Spacer()
            Button {
                withAnimation {
                    📱.現在の局面をブックマークする()
                    self.ブックマーク = .ブックマークを読み込む()
                }
            } label: {
                Label("現在の局面をブックマーク", systemImage: "bookmark")
                    .font(.body.weight(.semibold))
                    .padding(24)
            }
            .buttonStyle(.card)
            Spacer()
            Text("ブックマークに保存できる局面は1つだけです")
                .font(.caption.weight(.light))
                .foregroundStyle(.tertiary)
        }
        .onAppear { self.ブックマーク = .ブックマークを読み込む() }
    }
}

private struct 局面プレビュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 局面: 局面モデル
    private static let コマのサイズ: CGFloat = 30
    var body: some View {
        VStack(spacing: 12) {
            self.手駒プレビュー(局面, .玉側)
            self.盤面プレビュー(局面)
            self.手駒プレビュー(局面, .王側)
        }
    }
    private func 盤面プレビュー(_ 局面: 局面モデル) -> some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 9) { 行 in
                HStack(spacing: 0) {
                    ForEach(0 ..< 9) { 列 in
                        let 位置 = 行 * 9 + 列
                        if let 駒 = 局面.盤駒[位置] {
                            Text(🔠フォント.テキストを装飾(局面.この駒の表記(.盤駒(位置), 📱.🚩English表記) ?? "🐛",
                                                サイズ: Self.コマのサイズ,
                                                太字: 局面.直近の操作 == .盤駒(位置),
                                                下線: 局面.この駒にはアンダーラインが必要(.盤駒(位置), 📱.🚩English表記)))
                                .rotationEffect(駒.陣営 == .玉側 ? .degrees(180) : .zero)
                                .minimumScaleFactor(0.1)
                                .frame(width: Self.コマのサイズ, height: Self.コマのサイズ)
                        } else {
                            Color.clear
                                .frame(width: Self.コマのサイズ, height: Self.コマのサイズ)
                        }
                    }
                }
            }
        }
        .frame(width: Self.コマのサイズ * 9, height: Self.コマのサイズ * 9)
        .padding(2)
        .border(.primary)
    }
    private func 手駒プレビュー(_ 局面: 局面モデル, _ 陣営: 王側か玉側か) -> some View {
        HStack(spacing: 2) {
            ForEach(駒の種類.allCases) {
                if let 表記 = 局面.この駒の表記(.手駒(陣営, $0), 📱.🚩English表記) {
                    Text(🔠フォント.テキストを装飾(表記, サイズ: Self.コマのサイズ))
                        .minimumScaleFactor(0.1)
                }
            }
        }
        .rotationEffect(陣営 == .玉側 ? .degrees(180) : .zero)
        .frame(width: Self.コマのサイズ * 9, height: Self.コマのサイズ)
    }
    init(_ ｷｮｸﾒﾝ: 局面モデル) { self.局面 = ｷｮｸﾒﾝ }
}

private struct ガイドメニュー: View {
    var body: some View {
        List {
            Label("長押しすると「カーソルの枠線」を一時的に非表示にできます", systemImage: "square.dashed")
            Divider()
            Label("iCloudによって端末間でデータ(現在の局面/履歴/ブックマーク)が同期されます", systemImage: "icloud")
            Divider()
            VStack(spacing: 14) {
                Text("iOSアプリ等と異なり、Apple TVアプリでは以下の機能を対応していません")
                Text("""
                ・SharePlay
                ・セリフ体フォントオプション
                ・テキスト連携機能
                """)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 64)
        .padding(.horizontal, 300)
    }
}

private struct アプリについてメニュー: View {
    var body: some View {
        HStack {
            Spacer()
            Image("CombinedAppIcon")
                .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
                .shadow(radius: 12)
            Spacer()
            VStack(spacing: 32) {
                Spacer()
                Text(ℹ️appName)
                    .font(.largeTitle)
                Text(ℹ️appSubTitle)
                    .foregroundStyle(.secondary)
                Spacer()
                Link(destination: 🔗appStoreProductURL) {
                    Label("AppStoreリンク", systemImage: "link")
                        .padding(24)
                }
                .buttonStyle(.card)
            }
            Spacer()
        }
    }
}
