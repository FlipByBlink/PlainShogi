import SwiftUI

struct 🛠メニューボタン: View {
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

struct 🛠メニューコンテンツ: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        TabView {
            編集メニュー()
                .tabItem { Text("編集") }
            オプションメニュー()
                .tabItem { Text("オプション") }
            履歴メニュー()
                .tabItem { Text("履歴") }
            ブックマークメニュー()
                .tabItem { Text("ブックマーク") }
            アプリについてメニュー()
                .tabItem { Text("アプリについて") }
        }
        .background {
            Rectangle()
                .foregroundStyle(.background)
                .ignoresSafeArea()
        }
    }
}

private struct 編集メニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    var body: some View {
        List {
            self.盤面初期化ボタン()
            self.一手戻すボタン()
            self.増減モード開始ボタン()//タイトル: "駒を消したり増やしたりする")
            self.強調表示クリアボタン()
        }
        .padding(.top, 48)
        .padding(.horizontal, 480)
    }
    private func 盤面初期化ボタン() -> some View {
        Button {
            📱.盤面を初期化する()
        } label: {
            Label("盤面を初期化", systemImage: "arrow.counterclockwise")
        }
    }
    private func 一手戻すボタン() -> some View {
        Button {
            📱.一手戻す()
        } label: {
            Label("一手だけ戻す", systemImage: "arrow.backward.to.line")
        }
        .disabled(📱.局面.一手前の局面 == nil)
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

private struct オプションメニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @AppStorage("セリフ体") private var セリフ体: Bool = false
    @AppStorage("太字") private var 太字: Bool = false
    @AppStorage("サイズ") private var サイズ: 🔠フォント.サイズ = .標準
    var body: some View {
        NavigationStack {
            HStack {
                Image(systemName: "photo")
                    .font(.system(size: 300))
                    .padding(32)
                    .foregroundStyle(.tertiary)
                List {
                    Toggle(isOn: $📱.🚩上下反転) {
                        Label("上下反転", systemImage: "arrow.up.arrow.down")
                    }
                    Toggle(isOn: self.$セリフ体) {
                        Label("セリフ体", systemImage: "paintbrush.pointed")
                            .font(.system(.body, design: .serif))
                    }
                    Toggle(isOn: self.$太字) {
                        Label("太字", systemImage: "bold")
                            .font(.body.bold())
                    }
                    self.フォントサイズピッカー()
                    Toggle(isOn: $📱.🚩English表記) {
                        Label("English表記", systemImage: "p.circle")
                    }
                    Toggle(isOn: $📱.🚩直近操作強調表示機能オフ) {
                        Label("操作した直後の駒の強調表示を常に無効",
                              systemImage: "square.slash")
                    }
                }
            }
            .animation(.default, value: self.サイズ)
        }
    }
    private func フォントサイズピッカー() -> some View {
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
    private var 現在の局面とブックマークは同じ: Bool {
        📱.局面.更新日時 == self.ブックマーク?.更新日時
    }
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
                .disabled(self.現在の局面とブックマークは同じ)
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
            .disabled(self.現在の局面とブックマークは同じ)
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
                            Text(局面.この駒の表記(.盤駒(位置), 📱.🚩English表記) ?? "🐛")
                                .underline(局面.この駒にはアンダーラインが必要(.盤駒(位置), 📱.🚩English表記))
                                .fontWeight(局面.直近の操作 == .盤駒(位置) ? .bold : .light)
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
                    Text(表記)
                        .fontWeight(.light)
                        .minimumScaleFactor(0.1)
                }
            }
        }
        .rotationEffect(陣営 == .玉側 ? .degrees(180) : .zero)
        .frame(width: Self.コマのサイズ * 9, height: Self.コマのサイズ)
    }
    init(_ ｷｮｸﾒﾝ: 局面モデル) { self.局面 = ｷｮｸﾒﾝ }
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
                Text(ℹ️appName)
                    .font(.largeTitle)
                Text(ℹ️appSubTitle)
                    .foregroundStyle(.secondary)
                Link(destination: 🔗appStoreProductURL) {
                    Label("AppStore link", systemImage: "link")
                }
            }
            Spacer()
        }
    }
}
