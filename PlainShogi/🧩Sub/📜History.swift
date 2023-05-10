import SwiftUI

struct 📜履歴類セクション: View {
    var body: some View {
        Section {
            NavigationLink {
                📜ブックマークメニュー()
            } label: {
                Label("ブックマーク", systemImage: "bookmark")
            }
            NavigationLink {
                📜履歴メニュー()
            } label: {
                Label("履歴", systemImage: "clock")
            }
            .disabled(局面モデル.履歴.isEmpty)
        }
    }
}

struct 📜履歴メニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @State private var 🚩履歴削除完了: Bool = false
    var body: some View {
        List {
            Section {
                Text("直近の約30局面を履歴として保存します")
                    .padding(8)
                    .contextMenu { self.削除ボタン() }
                    .accessibilityHidden(true)
            }
            ForEach(局面モデル.履歴メニュー上での表示対象, id: \.更新日時) { 局面 in
                HStack {
                    🧾局面プレビュー(局面)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(局面.更新日付表記)
                            .font(.title3)
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
                            .font(.body.weight(.medium))
                        }
                        .buttonStyle(.bordered)
                        .dynamicTypeSize(...DynamicTypeSize.xLarge)
                    }
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .padding(.vertical, 8)
                }
                .padding()
            }
            if self.🚩履歴削除完了 { Text("これまでの履歴を削除しました") }
            if 局面モデル.履歴メニュー上での表示対象.isEmpty {
                Text("現在、履歴はありません")
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.default, value: self.🚩履歴削除完了)
        .navigationTitle("履歴")
    }
    private func 削除ボタン() -> some View {
        Button {
            局面モデル.履歴を全て削除する()
            self.🚩履歴削除完了 = true
            💥フィードバック.警告()
        } label: {
            Label("履歴を全て削除する", systemImage: "trash")
        }
        .accessibilityLabel("削除")
        .disabled(局面モデル.履歴.isEmpty)
    }
}

struct 📜ブックマークメニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @State private var ブックマーク: 局面モデル? = nil
    private var 現在の局面とブックマークは同じ: Bool { 📱.局面 == self.ブックマーク }
    var body: some View {
        List {
            Section {
                VStack(spacing: 20) {
                    if let ブックマーク {
                        🧾局面プレビュー(ブックマーク)
                    } else {
                        🧾局面プレビュー(.初期セット)
                            .foregroundStyle(.quaternary)
                    }
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
                .contextMenu { self.デバッグ用削除ボタン() }
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
            }
            Label("ブックマークに保存できる局面は1つだけです", systemImage: "1.circle")
        }
        .navigationTitle("ブックマーク")
        .onAppear { self.ブックマーク = .ブックマークを読み込む() }
    }
    private func デバッグ用削除ボタン() -> some View {
        Button("削除") {
            💾ICloud.remove(key: "ブックマーク")
            self.ブックマーク = nil
        }
    }
}
