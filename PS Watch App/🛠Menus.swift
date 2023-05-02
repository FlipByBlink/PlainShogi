import SwiftUI

struct 🛠メニュートップ: View {
    var body: some View {
        NavigationStack {
            List {
                編集メニュー()
                オプションメニュー()
                履歴メニュー()
                ブックマークメニュー()
                ガイドメニュー()
            }
            .navigationTitle(ℹ️appName)
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
                強調表示クリアボタン()
                self.盤面初期化ボタン()
                self.編集モード開始ボタン()
                self.一手戻すボタン()
            }
            .navigationTitle("編集")
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
                        Text("局面プレビュー(局面)")
                            .redacted(reason: .placeholder)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(局面.更新日付表記)
                            Text(局面.更新時刻表記)
                                .font(.subheadline)
                            Spacer()
                            Button {
                                📱.任意の局面を現在の局面として適用する(局面)
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("復元")
                                }
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
                        Text("局面プレビュー(仮)")
                            .frame(width: 100, height: 100)
                            .redacted(reason: .placeholder)
                        Button {
                            guard let ブックマーク else { return }
                            📱.任意の局面を現在の局面として適用する(ブックマーク)
                        } label: {
                            Label("復元", systemImage: "square.and.arrow.down")
                                .font(.body.weight(.medium))
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
