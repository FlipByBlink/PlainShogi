import SwiftUI

struct 🛠メニューボタン: View { // ⚙️
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    @State private var シートを表示: Bool = false
    private var 駒を選択していない: Bool {
        📱.選択中の駒 == .なし
    }
    var body: some View {
        Button {
            if self.駒を選択していない {
                self.シートを表示 = true
            } else {
                📱.駒の選択を解除する()
            }
            💥フィードバック.軽め()
        } label: {
            Group {
                if self.駒を選択していない {
                    Image(systemName: "gearshape")
                        .resizable()
                } else {
                    Image(systemName: "escape")
                        .resizable()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: self.マスの大きさ * 0.75,
                   height: self.マスの大きさ * 0.75)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: self.$シートを表示) {
            メニュートップ()
        }
        .animation(.default, value: self.駒を選択していない)
    }
}

private struct メニュートップ: View {
    var body: some View {
        NavigationStack {
            List {
                編集メニュー()
                オプションメニュー()
                履歴メニュー()
                ブックマークメニュー()
                ガイドメニュー()
            }
            .navigationTitle("メニュー")
        }
    }
}

private struct 編集メニュー: View {
    var body: some View {
        NavigationLink {
            Self.メニュー()
        } label: {
            Label("編集", systemImage: "hand.point.up.left")
        }
    }
    private struct メニュー: View {
        @EnvironmentObject private var 📱: 📱アプリモデル
        var body: some View {
            List {
                self.強調表示クリアボタン()
                self.盤面初期化ボタン()
                self.編集モード開始ボタン()
                self.一手戻すボタン()
            }
            .navigationTitle("編集")
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
        private func 盤面初期化ボタン() -> some View {
            Button {
                📱.盤面を初期化する()
            } label: {
                Label("盤面を初期化", systemImage: "arrow.counterclockwise")
            }
        }
        private func 編集モード開始ボタン() -> some View {
            Button {
                📱.編集モードを開始する()
            } label: {
                Label("駒を消したり増やしたりする", systemImage: "wand.and.rays")
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
    }
}

private struct オプションメニュー: View {
    var body: some View {
        NavigationLink {
            Self.メニュー()
        } label: {
            Label("オプション", systemImage: "gearshape")
        }
    }
   private struct メニュー: View {
       @EnvironmentObject private var 📱: 📱アプリモデル
       @AppStorage("太字") private var 太字: Bool = false
        var body: some View {
            List {
                Toggle(isOn: $📱.🚩上下反転) {
                    Label("上下反転", systemImage: "arrow.up.arrow.down")
                }
                Toggle(isOn: self.$太字) {
                    Label("太字", systemImage: "bold")
                        .font(.body.bold())
                }
                Toggle(isOn: $📱.🚩English表記) {
                    Label("English表記", systemImage: "p.circle")
                }
                Toggle(isOn: $📱.🚩直近操作強調表示機能オフ) {
                    Label("操作した直後の駒の強調表示を常に無効",
                          systemImage: "square.slash")
                }
            }
            .navigationTitle("オプション")
        }
    }
}

private struct 履歴メニュー: View {
    var body: some View {
        NavigationLink {
            Self.メニュー()
        } label: {
            Label("履歴", systemImage: "clock")
        }
    }
    private struct メニュー: View {
        @EnvironmentObject private var 📱: 📱アプリモデル
        var body: some View {
            List {
                Section {
                    Text("直近の約30局面を履歴として保存します")
                }
                ForEach(局面モデル.履歴.reversed(), id: \.更新日時) { 局面 in
                    HStack {
                        局面プレビュー(局面)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(局面.更新日付表記)
                            Text(局面.更新時刻表記)
                                .font(.subheadline)
                            Spacer()
                            Button {
                                📱.任意の局面を現在の局面として適用する(局面)
                            } label: {
                                Text("復元")
                                    .font(.caption.weight(.medium))
                            }
                            .buttonStyle(.bordered)
                            .dynamicTypeSize(...DynamicTypeSize.xLarge)
                        }
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                    }
                    .padding()
                }
            }
            .navigationTitle("履歴")
        }
    }
}

private struct ブックマークメニュー: View {
    var body: some View {
        NavigationLink {
            Self.メニュー()
        } label: {
            Label("ブックマーク", systemImage: "bookmark")
        }
    }
    private struct メニュー: View {
        @EnvironmentObject private var 📱: 📱アプリモデル
        @State private var ブックマーク: 局面モデル? = nil
        private var 現在の局面とブックマークは同じ: Bool {
            📱.局面.更新日時 == self.ブックマーク?.更新日時
        }
        var body: some View {
            List {
                Section {
                    VStack(spacing: 20) {
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
                        }
                        .buttonStyle(.bordered)
                        .disabled(self.現在の局面とブックマークは同じ)
                        .disabled(self.ブックマーク == nil)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                Section {
                    Button {
                        withAnimation {
                            📱.現在の局面をブックマークする()
                            self.ブックマーク = .ブックマークを読み込む()
                        }
                    } label: {
                        Label("現在の局面をブックマーク", systemImage: "bookmark")
                            .font(.body.weight(.semibold))
                    }
                    .disabled(self.現在の局面とブックマークは同じ)
                } footer: {
                    Label("ブックマークに保存できる局面は1つだけです", systemImage: "1.circle")
                }
            }
            .navigationTitle("ブックマーク")
        }
    }
}

private struct 局面プレビュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 局面: 局面モデル
    private static let コマのサイズ: CGFloat = 10
    var body: some View {
        VStack {
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
        .border(.primary, width: 0.66)
    }
    private func 手駒プレビュー(_ 局面: 局面モデル, _ 陣営: 王側か玉側か) -> some View {
        HStack {
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

private struct ガイドメニュー: View {
    var body: some View {
        NavigationLink {
            self.メニュー()
        } label: {
            Label("About App", systemImage: "questionmark")
        }
    }
    private func メニュー() -> some View {
        List {
            ZStack {
                Color.clear
                VStack(spacing: 8) {
                    Image("RoundedIcon")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    VStack(spacing: 6) {
                        Text(ℹ️appName)
                            .font(.system(.headline))
                            .tracking(1.5)
                            .opacity(0.75)
                        Text(ℹ️appSubTitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .lineLimit(2)
                    .minimumScaleFactor(0.1)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
            }
            Link(destination: 🔗appStoreProductURL) {
                Label("Open AppStore page", systemImage: "link")
            }
        }
    }
}
