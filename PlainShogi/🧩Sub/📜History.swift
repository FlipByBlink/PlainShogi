import SwiftUI

struct 履歴リンク: View {
    var body: some View {
        NavigationLink {
            履歴メニュー()
        } label: {
            Label("履歴", systemImage: "clock")
        }
    }
}

struct 履歴メニュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @State private var 🚩履歴削除完了: Bool = false
    private let コマのサイズ: CGFloat = 20
    var body: some View {
        List {
            Section {
                Text("直近の約30局面を履歴として保存します")
                    .padding(8)
                    .contextMenu { self.削除ボタン() }
                    .accessibilityHidden(true)
            }
            ForEach(局面モデル.履歴.reversed(), id: \.更新日時) { 局面 in
                HStack {
                    VStack {
                        self.手駒プレビュー(局面, .玉側)
                        self.盤面プレビュー(局面)
                        self.手駒プレビュー(局面, .王側)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        if let 更新日時 = 局面.更新日時 {
                            Text(更新日時.formatted(.dateTime.day().month()))
                                .font(.title3)
                            Text(更新日時.formatted(.dateTime.hour().minute().second()))
                                .font(.subheadline)
                        }
                        Spacer()
                        Button {
                            withAnimation { 📱.履歴を復元する(局面) }
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
            if 局面モデル.履歴.isEmpty {
                Text("現在、履歴はありません")
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.default, value: self.🚩履歴削除完了)
        .navigationTitle("履歴")
    }
    private func 盤面プレビュー(_ 局面: 局面モデル) -> some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 9) { 行 in
                HStack(spacing: 0) {
                    ForEach(0 ..< 9) { 列 in
                        let 位置 = 行 * 9 + 列
                        if let 駒 = 局面.盤駒[位置] {
                            let 表記 = 局面.盤上のこの駒の表記(位置, 📱.🚩English表記) ?? "🐛"
                            Text(表記)
                                .underline((駒.陣営 == .玉側) && (表記 == "S" || 表記 == "N"))
                                .fontWeight(局面.直近の操作 == .盤駒(位置) ? .bold : .light)
                                .rotationEffect(駒.陣営 == .玉側 ? .degrees(180) : .zero)
                                .minimumScaleFactor(0.1)
                                .frame(width: self.コマのサイズ, height: self.コマのサイズ)
                        } else {
                            Color.clear
                                .frame(width: self.コマのサイズ, height: self.コマのサイズ)
                        }
                    }
                }
            }
        }
        .frame(width: self.コマのサイズ * 9, height: self.コマのサイズ * 9)
        .padding(2)
        .border(.primary, width: 0.66)
    }
    private func 手駒プレビュー(_ 局面: 局面モデル, _ 陣営: 王側か玉側か) -> some View {
        HStack {
            ForEach(駒の種類.allCases) { 駒 in
                if let 数 = 局面.手駒[陣営]?.配分[駒] {
                    if 数 > 0 {
                        let 表記 = 📱.🚩English表記 ? 駒.English生駒表記 : 駒.rawValue
                        Text(表記 + 数.description)
                            .fontWeight(.light)
                            .minimumScaleFactor(0.1)
                    }
                }
            }
        }
        .frame(width: self.コマのサイズ * 9, height: self.コマのサイズ)
    }
    private func 削除ボタン() -> some View {
        Button {
            局面モデル.履歴を全て削除する()
            self.🚩履歴削除完了 = true
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        } label: {
            Label("履歴を全て削除する", systemImage: "trash")
        }
        .accessibilityLabel("削除")
        .disabled(局面モデル.履歴.isEmpty)
    }
}
