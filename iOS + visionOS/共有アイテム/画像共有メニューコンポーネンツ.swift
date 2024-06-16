import SwiftUI

struct 画像共有メニューコンポーネンツ: View {
    var body: some View {
        Self.プレビュー()
        Self.写真共有ボタン()
    }
}

private extension 画像共有メニューコンポーネンツ {
    private struct プレビュー: View {
        @EnvironmentObject var モデル: アプリモデル
        @State private var イメージ: Image?
        var body: some View {
            HStack {
                Spacer()
                Group {
                    if let イメージ {
                        イメージ
                            .resizable()
                    } else {
                        Color.white
                    }
                }
                .frame(width: 240, height: 240)
                .shadow(radius: 3)
                .padding()
                Spacer()
            }
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            .task { self.イメージをロード() }
            .onChange(of: モデル.表示中のシート) {
                if [.メニュー, .画像共有].contains($0) { self.イメージをロード() }
            }
        }
        private func イメージをロード() {
            self.イメージ = try? 画像書き出し.画像を取得()
        }
    }
    private struct 写真共有ボタン: View {
        @EnvironmentObject var モデル: アプリモデル
        var body: some View {
            ShareLink(item: Self.アイテム(),
                      preview: .init("盤面画像", icon: self.プレビューアイコン)) {
                Label("共有", systemImage: "square.and.arrow.up")
            }
        }
        private var プレビューアイコン: Image {
            (try? 画像書き出し.画像を取得()) ?? .init(systemName: "photo")
        }
        private struct アイテム: Transferable {
            static var transferRepresentation: some TransferRepresentation {
                FileRepresentation(exportedContentType: .png) { _ in
                    SentTransferredFile(画像書き出し.一時ファイルURL)
                }
                .suggestedFileName(画像書き出し.ファイル名)
            }
        }
    }
}
