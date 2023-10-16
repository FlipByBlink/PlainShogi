import SwiftUI

struct 履歴類セクション: View {
    var body: some View {
        Section {
            NavigationLink {
                ブックマークメニュー()
            } label: {
                Label("ブックマーク", systemImage: "bookmark")
            }
            NavigationLink {
                履歴メニュー()
            } label: {
                Label("履歴", systemImage: "clock")
            }
            .disabled(局面モデル.履歴.isEmpty)
        }
    }
}

struct 履歴メニュー: View {
    @EnvironmentObject var モデル: アプリモデル
    @State private var 履歴削除完了: Bool = false
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
                    局面プレビュー(局面)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(局面.更新日付表記)
                            .font(.title3)
                        Text(局面.更新時刻表記)
                            .font(.subheadline)
                        Spacer()
                        Button {
                            モデル.任意の局面を現在の局面として適用する(局面)
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
            if self.履歴削除完了 { Text("これまでの履歴を削除しました") }
            if 局面モデル.履歴メニュー上での表示対象.isEmpty {
                Text("現在、履歴はありません")
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.default, value: self.履歴削除完了)
        .navigationTitle("履歴")
    }
    private func 削除ボタン() -> some View {
        Button {
            局面モデル.履歴を全て削除する()
            self.履歴削除完了 = true
            フィードバック.警告()
        } label: {
            Label("履歴を全て削除する", systemImage: "trash")
        }
        .accessibilityLabel("削除")
        .disabled(局面モデル.履歴.isEmpty)
    }
}
