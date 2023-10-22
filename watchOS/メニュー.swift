import SwiftUI

struct メニュートップ: View {
    @Environment(\.dismiss) var dismiss
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
        @EnvironmentObject var モデル: アプリモデル
        var body: some View {
            List {
                Button {
                    モデル.盤面を初期化する()
                } label: {
                    Label("盤面を初期化", systemImage: "arrow.counterclockwise")
                }
                Button {
                    モデル.一手戻す()
                } label: {
                    Label("一手だけ戻す", systemImage: "arrow.backward.to.line")
                }
                .disabled(モデル.局面.一手前の局面 == nil)
                Button {
                    モデル.増減モードを開始する()
                } label: {
                    Label("駒を消したり増やしたりする", systemImage: "wand.and.rays")
                }
                Button {
                    モデル.強調表示をクリア()
                } label: {
                    Label("強調表示をクリア", systemImage: "square.dashed")
                }
                .disabled(モデル.何も強調表示されていない)
                .disabled(モデル.強調表示常時オフかつ駒が選択されていない)
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
       @EnvironmentObject var モデル: アプリモデル
        var body: some View {
            List {
                Toggle(isOn: $モデル.上下反転) {
                    Label("上下反転", systemImage: "arrow.up.arrow.down")
                }
                Toggle(isOn: $モデル.太字) {
                    Label("太字", systemImage: "bold")
                        .font(.body.bold())
                }
                Toggle(isOn: $モデル.english表記) {
                    Label("English表記", systemImage: "p.circle")
                }
                Toggle(isOn: $モデル.直近操作強調表示機能オフ) {
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
        @EnvironmentObject var モデル: アプリモデル
        var body: some View {
            List {
                Section {
                    Text("直近の約30局面を履歴として保存します")
                }
                ForEach(局面モデル.履歴メニュー上での表示対象, id: \.更新日時) { 局面 in
                    HStack {
                        局面プレビュー(局面)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(局面.更新日付表記)
                            Text(局面.更新時刻表記)
                                .font(.subheadline)
                            Spacer()
                            Button("復元") {
                                モデル.任意の局面を現在の局面として適用する(局面)
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
        @EnvironmentObject var モデル: アプリモデル
        @State private var ブックマーク: 局面モデル? = nil
        private var 現在の局面とブックマークは同じ: Bool { モデル.局面 == self.ブックマーク }
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
                            モデル.任意の局面を現在の局面として適用する(ブックマーク)
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
                            モデル.現在の局面をブックマークする()
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

private struct ガイドメニュー: View {
    var body: some View {
        NavigationLink {
            Self.補足セクション()
        } label: {
            Label("補足", systemImage: "info")
        }
        NavigationLink {
            ℹ️AboutAppMenu()
        } label: {
            Label("アプリについて", systemImage: "questionmark")
        }
    }
    private static func 補足セクション() -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Label("iCloudによって端末間でデータ(局面/履歴/ブックマーク)が同期されます", systemImage: "icloud")
                    Text("iCloud同期は簡易的な用途を想定しています。「同時に起動している端末間での同期」といったリアルタイム性の高い用途は想定していません。")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("iOSアプリと異なり、watchOSアプリでは以下の機能を対応していません")
                    Text("""
                ・SharePlay
                ・セリフ体フォントオプション
                ・駒のサイズオプション
                ・画像書き出し機能
                ・テキスト書き出し/読み込み機能
                """)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                }
            } header: {
                Text("補足")
            }
        }
    }
}
