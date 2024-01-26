import SwiftUI

struct テキスト共有メニューコンポーネンツ: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        self.プレビュー()
        Self.テキスト共有ボタン()
        Self.コピーボタン()
        Self.ペーストインポートボタン()
        Self.ファイルインポートボタン()
        Self.ドラッグアンドドロップ共有メニューリンク()
    }
}

private extension テキスト共有メニューコンポーネンツ {
    private func プレビュー() -> some View {
        HStack {
            Spacer()
            Text(モデル.現在の盤面をテキストに変換する())
                .textSelection(.enabled)
                .padding()
                .accessibilityHidden(true)
            Spacer()
        }
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }
    private struct テキスト共有ボタン: View {
        @EnvironmentObject var モデル: アプリモデル
        var body: some View {
            ShareLink(item: Self.アイテム(テキスト: モデル.現在の盤面をテキストに変換する()),
                      preview: .init("盤面テキスト")) {
                Label("共有", systemImage: "square.and.arrow.up")
            }
        }
        private struct アイテム: Transferable {
            var テキスト: String
            static var transferRepresentation: some TransferRepresentation {
                DataRepresentation(exportedContentType: .data) {
                    if let 値 = $0.テキスト.data(using: .utf8) {
                        値
                    } else {
                        throw Self.エラー.データ化失敗
                    }
                }
                .suggestedFileName(Self.ファイル名)
                ProxyRepresentation(exporting: \.テキスト)
                    .suggestedFileName(Self.ファイル名)
            }
            private static var ファイル名: String {
                .init(localized: "☖ Plain将棋盤 ")
                + Date.now.formatted(.dateTime.year().month().day())
                + ".txt"
            }
            private enum エラー: Error {
                case データ化失敗
            }
        }
    }
    private struct コピーボタン: View {
        @EnvironmentObject var モデル: アプリモデル
        @State private var 完了: Bool = false
        var body: some View {
            Button {
                モデル.現在の局面をテキストとしてコピー()
                withAnimation { self.完了 = true }
                システムフィードバック.成功()
            } label: {
                Label("プレーンテキストとして「コピー」", systemImage: "doc.on.doc")
                    .foregroundStyle(self.完了 ? .secondary : .primary)
            }
            .badge(self.完了 ? Text(Image(systemName: "checkmark")) : nil)
        }
    }
    private struct ペーストインポートボタン: View {
        @EnvironmentObject var モデル: アプリモデル
        @State private var 失敗アラート: Bool = false
        @State private var 失敗概要: String?
        var body: some View {
            Button {
                do {
                    try モデル.テキストを局面としてペースト()
                    モデル.表示中のシート = nil
                } catch {
                    self.失敗アラート = true
                    self.失敗概要 = error.localizedDescription
                }
            } label: {
                Label("プレーンテキストを「貼り付け」して読み込む", systemImage: "doc.on.clipboard")
            }
            .alert("読み込みに失敗しました", isPresented: self.$失敗アラート) {
                Button("了解しました") { self.失敗概要 = nil }
            } message: {
                if let 失敗概要 { Text(失敗概要) }
            }
        }
    }
    private struct ファイルインポートボタン: View {
        @EnvironmentObject var モデル: アプリモデル
        @State private var インポーター表示: Bool = false
        @State private var 失敗アラート: Bool = false
        @State private var 失敗概要: String?
        var body: some View {
            Button {
                self.インポーター表示.toggle()
            } label: {
                Label("テキストファイルを読み込む", systemImage: "doc.plaintext")
            }
            .fileImporter(isPresented: self.$インポーター表示, allowedContentTypes: [.plainText]) {
                switch $0 {
                    case .success(let url):
                        guard url.startAccessingSecurityScopedResource() else {
                            self.失敗アラート = true
                            return
                        }
                        do {
                            try モデル.テキストを局面に変換して読み込む(try String(contentsOf: url))
                            モデル.表示中のシート = nil
                        } catch {
                            self.失敗アラート = true
                            self.失敗概要 = error.localizedDescription
                        }
                        url.stopAccessingSecurityScopedResource()
                    case .failure(let error):
                        self.失敗アラート = true
                        self.失敗概要 = error.localizedDescription
                }
            }
            .alert("読み込みに失敗しました", isPresented: self.$失敗アラート) {
                Button("了解しました") { self.失敗概要 = nil }
            } message: {
                if let 失敗概要 { Text(失敗概要) }
            }
        }
    }
    private struct ドラッグアンドドロップ共有メニューリンク: View {
        @EnvironmentObject var モデル: アプリモデル
        var body: some View {
            NavigationLink {
                List {
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
                }
                .navigationTitle("他のアプリとドラッグ&ドロップ")
                .navigationBarTitleDisplayMode(.inline)
            } label: {
                Label("ドラッグ&ドロップについて", systemImage: "hand.draw")
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
}
