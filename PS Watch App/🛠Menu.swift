import SwiftUI

struct 🛠メニューボタン: View { // ⚙️
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 駒を選択していない: Bool { 📱.選択中の駒 == .なし }
    private var モード: Self.モード切り替え {
        if 📱.編集中 {
            return .編集完了
        } else if 📱.選択中の駒 == .なし {
            return .メニュー
        } else {
            return .駒選択解除
        }
    }
    private var アイコンネーム: String {
        switch self.モード {
            case .メニュー: return "gearshape"
            case .駒選択解除: return "escape"
            case .編集完了: return "checkmark.circle.fill"
        }
    }
    var body: some View {
        Button {
            switch self.モード {
                case .メニュー: 📱.シートを表示 = .メニュー
                case .駒選択解除: 📱.駒の選択を解除する()
                case .編集完了: 📱.編集モードを終了する()
            }
            💥フィードバック.軽め()
        } label: {
            Image(systemName: self.アイコンネーム)
                .imageScale(.small)
                .frame(width: self.マスの大きさ * 0.75,
                       height: self.マスの大きさ * 0.75)
                .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .sheet(item: $📱.シートを表示) {
            switch $0 {
                case .メニュー: メニュートップ()
                case .手駒編集(let 陣営): 手駒編集メニュー(陣営)
                default: Text("🐛")
            }
        }
        .animation(.default, value: self.駒を選択していない)
    }
    private enum モード切り替え {
        case メニュー, 駒選択解除, 編集完了
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
                Button {
                    📱.盤面を初期化する()
                } label: {
                    Label("盤面を初期化", systemImage: "arrow.counterclockwise")
                }
                Button {
                    📱.一手戻す()
                } label: {
                    Label("一手だけ戻す", systemImage: "arrow.backward.to.line")
                }
                .disabled(📱.局面.一手前の局面 == nil)
                Button {
                    📱.編集モードを開始する()
                } label: {
                    Label("駒を消したり増やしたりする", systemImage: "wand.and.rays")
                }
                Button {
                    📱.強調表示をクリア()
                } label: {
                    Label("強調表示をクリア", systemImage: "square.dashed")
                }
                .disabled(📱.何も強調表示されていない)
                .disabled(📱.強調表示常時オフかつ駒が選択されていない)
            }
            .navigationTitle("編集")
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
                            Button("復元") {
                                📱.任意の局面を現在の局面として適用する(局面)
                            }
                            .font(.caption.weight(.medium))
                            .buttonStyle(.bordered)
                        }
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                    }
                    .padding(.vertical, 8)
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
                    VStack {
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
            .onAppear { self.ブックマーク = .ブックマークを読み込む() }
        }
    }
}

private struct 局面プレビュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 局面: 局面モデル
    private static let コマのサイズ: CGFloat = 9
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

private struct 手駒編集メニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 陣営: 王側か玉側か
    var body: some View {
        List {
            ForEach(駒の種類.allCases) { 職名 in
                HStack {
                    Button {
                        📱.編集モードでこの手駒を一個減らす(self.陣営, 職名)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                            .imageScale(.small)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    HStack(spacing: 12) {
                        Text(📱.手駒編集シートの駒の表記(職名, self.陣営))
                            .font(.headline)
                        Text(📱.局面.この手駒の数(self.陣営, 職名).description)
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                    .minimumScaleFactor(0.5)
                    Spacer()
                    Button {
                        📱.編集モードでこの手駒を一個増やす(self.陣営, 職名)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                            .imageScale(.small)
                    }
                    .buttonStyle(.plain)
                }
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            }
        }
        .listStyle(.plain)
        .navigationTitle(self.陣営 == .王側 ? "王側の手駒" : "玉側の手駒")
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
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
