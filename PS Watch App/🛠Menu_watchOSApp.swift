import SwiftUI

struct 🛠ツールボタン: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.マスの大きさ) private var マスの大きさ
    private var 駒を選択していない: Bool { 📱.選択中の駒 == .なし }
    private var モード: Self.モード切り替え {
        if 📱.増減モード中 { return .増減モード完了 }
        return (📱.選択中の駒 == .なし) ? .メニュー : .駒選択解除
    }
    var body: some View {
        Button(action: self.アクション) {
            Image(systemName: self.モード.アイコン)
                .resizable()
                .scaledToFit()
                .padding(9)
                .frame(width: self.マスの大きさ + 12, height: self.マスの大きさ + 12)
        }
        .buttonStyle(.plain)
        .sheet(item: $📱.シートを表示) {
            switch $0 {
                case .メニュー: メニュートップ()
                case .手駒増減(let 陣営): 手駒増減メニュー(陣営)
                default: Text("🐛")
            }
        }
        .animation(.default, value: self.駒を選択していない)
    }
    private func アクション() {
        switch self.モード {
            case .メニュー:
                📱.シートを表示 = .メニュー
                💥フィードバック.軽め()
            case .駒選択解除:
                📱.駒の選択を解除する()
                💥フィードバック.軽め()
            case .増減モード完了:
                📱.増減モードを終了する()
        }
    }
    private enum モード切り替え {
        case メニュー, 駒選択解除, 増減モード完了
        var アイコン: String {
            switch self {
                case .メニュー: return "gearshape"
                case .駒選択解除: return "escape"
                case .増減モード完了: return "checkmark.circle.fill"
            }
        }
    }
}

private struct メニュートップ: View {
    @Environment(\.dismiss) private var dismiss
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
            .toolbar { 閉じるボタン(self.dismiss) }
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
                    📱.増減モードを開始する()
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
                ForEach(局面モデル.履歴メニュー上での表示対象, id: \.更新日時) { 局面 in
                    HStack {
                        🧾局面プレビュー(局面)
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
        private var 現在の局面とブックマークは同じ: Bool { 📱.局面 == self.ブックマーク }
        var body: some View {
            List {
                Section {
                    VStack {
                        if let ブックマーク {
                            🧾局面プレビュー(ブックマーク)
                        } else {
                            🧾局面プレビュー(.初期セット)
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

private struct 手駒増減メニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.dismiss) private var dismiss
    private var 陣営: 王側か玉側か
    var body: some View {
        List {
            ForEach(駒の種類.allCases) { 職名 in
                HStack {
                    Button {
                        📱.増減モードでこの手駒を一個減らす(self.陣営, 職名)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title2)
                            .imageScale(.small)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    HStack(spacing: 12) {
                        Text(🔠文字.装飾(📱.手駒増減メニューの駒の表記(職名, self.陣営),
                                     フォント: .system(size: 24, weight: .bold)))
                        Text(📱.局面.この手駒の数(self.陣営, 職名).description)
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                    .minimumScaleFactor(0.5)
                    Spacer()
                    Button {
                        📱.増減モードでこの手駒を一個増やす(self.陣営, 職名)
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
        .toolbar { 閉じるボタン(self.dismiss) }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か) { self.陣営 = ｼﾞﾝｴｲ }
}

private struct 閉じるボタン: ToolbarContent {
    private var dismiss: DismissAction
    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                self.dismiss()
                💥フィードバック.軽め()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
    init(_ dismiss: DismissAction) { self.dismiss = dismiss }
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
            Self.補足セクション()
        }
    }
    private static func 補足セクション() -> some View {
        Section {
            Label("iCloudによって端末間でデータ(局面/履歴/ブックマーク)が同期されます",
                  systemImage: "icloud")
            VStack(alignment: .leading, spacing: 4) {
                Text("iOSアプリと異なり、watchOSアプリでは以下の機能を対応していません")
                Text("""
                ・SharePlay
                ・セリフ体フォントオプション
                ・駒のサイズオプション
                ・テキスト連携機能
                """)
                .font(.caption)
            }
        } header: {
            Text("補足")
        }
    }
}
