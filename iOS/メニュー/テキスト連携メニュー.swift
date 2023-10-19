import SwiftUI

struct テキスト連携メニューリンク: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        NavigationLink {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(モデル.現在の盤面をテキストに変換する())
                            .textSelection(.enabled)
                        Self.コピーボタン()
                    }
                    .padding()
                } header: {
                    Text("テキスト書き出し例")
                }
                Section {
                    VStack(alignment: .leading, spacing: 2) {
                        Label("駒を他のアプリへドラッグして盤面をテキストとして書き出せます。",
                              systemImage: "square.and.arrow.up")
                        Self.テキスト変換プレビュー(フォルダー名: "TextExport", 枚数: 4)
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    VStack(alignment: .leading, spacing: 2) {
                        Label("他のアプリからテキストを盤上にドロップして盤面を読み込めます。「☗」が先頭のテキストをドロップしてください。",
                              systemImage: "square.and.arrow.down")
                        Self.テキスト変換プレビュー(フォルダー名: "TextImport", 枚数: 5)
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    Button {
                        モデル.テキストを局面としてペースト()
                        モデル.表示中のシート = nil
                    } label: {
                        Label("テキストを局面としてペースト", systemImage: "doc.on.clipboard")
                    }
                }
            }
            .navigationTitle("テキスト機能")
        } label: {
            Label("テキスト書き出し/読み込み機能", systemImage: "square.and.arrow.up.on.square")
        }
    }
}

private extension テキスト連携メニューリンク {
    private struct コピーボタン: View {
        @EnvironmentObject var モデル: アプリモデル
        @State private var 完了: Bool = false
        var body: some View {
            HStack {
                Spacer()
                if self.完了 { Image(systemName: "checkmark") }
                Button {
                    モデル.現在の局面をテキストとしてコピー()
                    withAnimation { self.完了 = true }
                } label: {
                    Label("テキストとしてコピー", systemImage: "doc.on.doc")
                        .foregroundStyle(self.完了 ? .secondary : .primary)
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)
            }
        }
    }
    private struct テキスト変換プレビュー: View {
        var フォルダー名: String
        var 枚数: Int
        private let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()
        @State private var 表示中の画像: Int = 0
        var body: some View {
            VStack(spacing: 4) {
                ZStack {
                    ForEach(0 ..< self.枚数, id: \.self) { 番号 in
                        if 番号 <= self.表示中の画像 {
                            Image(self.フォルダー名 + "/" + 番号.description)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                ProgressView(value: Double(self.表示中の画像), total: Double(self.枚数 - 1))
                    .grayscale(1)
                    .padding(.horizontal)
                    .accessibilityHidden(true)
            }
            .onReceive(self.timer) { _ in
                withAnimation(.default.speed(0.5)) {
                    if self.表示中の画像 == self.枚数 - 1 {
                        self.表示中の画像 = 0
                    } else {
                        self.表示中の画像 += 1
                    }
                }
            }
            .padding(8)
        }
    }
}
