import SwiftUI

struct サイドバー: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
    @State private var 表示: Bool = false
    @FocusState private var 初期フォーカス: Bool
    @AppStorage("ｻｲﾄﾞﾊﾞｰﾎﾞﾀﾝ非表示") var サイドバー用ボタン常時非表示: Bool = false
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
        guard !モデル.増減モード中 else { モデル.増減モードを終了する(); return }
        if self.表示 == false {
            self.表示 = true
            self.初期フォーカス = true
        } else {
            self.表示 = false
        }
    }
    private func サイドバー呼び出しボタン() -> some View {
        Group {
            if !モデル.増減モード中, !self.サイドバー用ボタン常時非表示 {
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
                self.モデル.表示中のシート = .メニュー
                self.表示 = false
            } label: {
                Label("メニューを表示", systemImage: "gearshape")
            }
            Divider()
            盤面初期化ボタン()
            一手戻すボタン()
            Toggle(isOn: $モデル.上下反転) {
                Label("上下反転", systemImage: "arrow.up.arrow.down")
            }
            Toggle(isOn: $モデル.太字) {
                Label("太字", systemImage: "bold")
            }
            Toggle(isOn: $モデル.english表記) {
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
        @EnvironmentObject var モデル: アプリモデル
        @Environment(\.dismiss) var dismiss
        @Binding var サイドバーを表示: Bool
        var body: some View {
            List {
                Picker(selection: $モデル.サイズ) {
                    ForEach(字体.サイズ.allCases) { Text($0.ローカライズキー) }
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

struct メニューコンテンツ: View {
    @EnvironmentObject var モデル: アプリモデル
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
    @EnvironmentObject var モデル: アプリモデル
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
            モデル.増減モードを開始する()
        } label: {
            Label("駒を消したり増やしたりする", systemImage: "wand.and.rays")
        }
    }
    private func 強調表示クリアボタン() -> some View {
        Button {
            モデル.強調表示をクリア()
        } label: {
            Label("強調表示をクリア", systemImage: "square.dashed")
        }
        .disabled(モデル.何も強調表示されていない)
        .disabled(モデル.強調表示常時オフかつ駒が選択されていない)
    }
}

private struct 盤面初期化ボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    @State private var 初期化直後: Bool = false
    var body: some View {
        Button {
            モデル.盤面を初期化する()
            self.初期化直後 = true
        } label: {
            Label("盤面を初期化", systemImage: "arrow.counterclockwise")
        }
        .disabled(self.初期化直後)
    }
}

private struct 一手戻すボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        Button {
            モデル.一手戻す()
        } label: {
            Label("一手だけ戻す", systemImage: "arrow.backward.to.line")
        }
        .disabled(モデル.局面.一手前の局面 == nil)
    }
}

private struct オプションメニュー: View {
    @EnvironmentObject var モデル: アプリモデル
    @AppStorage("ｻｲﾄﾞﾊﾞｰﾎﾞﾀﾝ非表示") var サイドバー用ボタン常時非表示: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Toggle(isOn: $モデル.上下反転) {
                    Label("上下反転", systemImage: "arrow.up.arrow.down")
                }
                Toggle(isOn: $モデル.太字) {
                    Label("太字", systemImage: "bold")
                }
                Picker(selection: $モデル.サイズ) {
                    ForEach(字体.サイズ.allCases) { Text($0.ローカライズキー) }
                } label: {
                    Label("駒のサイズ", systemImage: "magnifyingglass")
                }
                .pickerStyle(.navigationLink)
                Toggle(isOn: $モデル.english表記) {
                    Label("English表記", systemImage: "p.circle")
                }
                Toggle(isOn: $モデル.直近操作強調表示機能オフ) {
                    Label("操作した直後の駒の強調表示を常に無効",
                          systemImage: "square.slash")
                }
                Divider()
                Toggle(isOn: self.$サイドバー用ボタン常時非表示) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("サイドバー呼び出しボタンを常に非表示",
                              systemImage: "gear.badge.xmark")
                        Text("戻るボタンを押すとサイドバーを表示できます")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .padding(.top, 64)
            .padding(.horizontal, 400)
        }
    }
}

private struct 履歴メニュー: View {
    @EnvironmentObject var モデル: アプリモデル
    private var 表示対象: [局面モデル] { 局面モデル.履歴メニュー上での表示対象 }
    var body: some View {
        List {
            ForEach(self.表示対象, id: \.更新日時) { 局面 in
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
                        モデル.任意の局面を現在の局面として適用する(局面)
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
                .padding(.top, 局面 == self.表示対象.first ? 120 : 0)
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
    @EnvironmentObject var モデル: アプリモデル
    @State private var ブックマーク: 局面モデル? = nil
    private var 現在の局面とブックマークは同じ: Bool { モデル.局面 == self.ブックマーク }
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
                    モデル.任意の局面を現在の局面として適用する(ブックマーク)
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
                    モデル.現在の局面をブックマークする()
                    self.ブックマーク = .ブックマークを読み込む()
                }
            } label: {
                Label("現在の局面をブックマーク", systemImage: "bookmark")
                    .font(.body.weight(.semibold))
                    .padding(24)
            }
            .buttonStyle(.card)
            .foregroundStyle(self.現在の局面とブックマークは同じ ? .tertiary : .primary)
            Spacer()
            Text("ブックマークに保存できる局面は1つだけです")
                .font(.caption.weight(.light))
                .foregroundStyle(.tertiary)
        }
        .onAppear { self.ブックマーク = .ブックマークを読み込む() }
    }
}

private struct ガイドメニュー: View {
    var body: some View {
        List {
            Label("選択ボタンを長押しすると「カーソルの枠線」を一時的に非表示にできます", systemImage: "square.dashed")
            Divider()
            Label("一般のApple TVアプリ同様にゲームコントローラーでもこのアプリを操作できます", systemImage: "gamecontroller")
            Divider()
            VStack(alignment: .leading, spacing: 14) {
                Label("iCloudによって端末間でデータ(局面/履歴/ブックマーク)が同期されます", systemImage: "icloud")
                Text("iCloud同期は簡易的な用途を想定しています。「同時に起動している端末間での同期」といったリアルタイム性の高い用途は想定していません。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Divider()
            VStack(alignment: .leading, spacing: 14) {
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
                Text(🗒️StaticInfo.appName)
                    .font(.largeTitle)
                Text(🗒️StaticInfo.appSubTitle)
                    .foregroundStyle(.secondary)
                Spacer()
                Link(destination: 🗒️StaticInfo.appStoreProductURL) {
                    Label("App Storeリンク", systemImage: "link")
                        .padding(24)
                }
                .buttonStyle(.card)
            }
            Spacer()
        }
    }
}
