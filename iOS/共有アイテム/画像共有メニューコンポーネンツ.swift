import SwiftUI
import UIKit

struct 画像共有メニューコンポーネンツ: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        self.プレビュー()
        Self.写真共有ボタン()
        Self.写真アプリ保存ボタン()
    }
}

private extension 画像共有メニューコンポーネンツ {
    private func プレビュー() -> some View {
        HStack {
            Spacer()
            if let 画像 = try? 画像書き出し.画像を取得() {
                画像
                    .resizable()
                    .frame(width: 240, height: 240)
                    .shadow(radius: 3)
                    .padding()
            }
            Spacer()
        }
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }
    private struct 写真共有ボタン: View {
        var body: some View {
            if let 画像 = try? 画像書き出し.画像を取得() {
                ShareLink(item: Self.アイテム(),
                          preview: .init("盤面画像", icon: 画像)) {
                    Label("共有", systemImage: "square.and.arrow.up")
                }
            }
        }
        private struct アイテム: Transferable {
            static var transferRepresentation: some TransferRepresentation {
                DataRepresentation(exportedContentType: .png) { _ in
                    try .init(contentsOf: 画像書き出し.一時ファイルURL)
                }
                .suggestedFileName(画像書き出し.ファイル名)
                ProxyRepresentation { _ in try 画像書き出し.画像を取得() }
            }
        }
    }
    private struct 写真アプリ保存ボタン: View {
        @EnvironmentObject var モデル: アプリモデル
        @StateObject private var セーバー: Self.画像セーバー = .init()
        var body: some View {
            Button {
                do {
                    if let uiImage = UIImage(data: try Data(contentsOf: 画像書き出し.一時ファイルURL)) {
                        self.セーバー.写真アルバムへ保存(画像: uiImage)
                    } else {
                        self.セーバー.失敗アラート = true
                        self.セーバー.失敗概要 = String(localized: "画像化失敗")
                    }
                } catch {
                    self.セーバー.失敗アラート = true
                    self.セーバー.失敗概要 = error.localizedDescription
                }
            } label: {
                Label("「写真」アプリに保存", systemImage: "photo.badge.arrow.down")
                    .foregroundStyle(self.セーバー.保存完了 ? .secondary : .primary)
            }
            .badge(self.セーバー.保存完了 ? Text(Image(systemName: "checkmark")) : nil)
            .alert("保存に失敗しました", isPresented: self.$セーバー.失敗アラート) {
                Button("了解しました") { self.セーバー.失敗概要 = nil }
            } message: {
                if let 概要 = self.セーバー.失敗概要 { Text(概要) }
            }
        }
        private class 画像セーバー: NSObject, ObservableObject {
            @Published var 保存完了: Bool = false
            @Published var 失敗アラート: Bool = false
            @Published var 失敗概要: String?
            func 写真アルバムへ保存(画像: UIImage) {
                UIImageWriteToSavedPhotosAlbum(画像, self, #selector(保存結果通知), nil)
            }
            @objc func 保存結果通知(_ image: UIImage,
                            didFinishSavingWithError error: Error?,
                            contextInfo: UnsafeRawPointer) {
                if let error {
                    self.失敗アラート = true
                    self.失敗概要 = error.localizedDescription
                    フィードバック.エラー()
                } else {
                    withAnimation { self.保存完了 = true }
                    フィードバック.成功()
                }
            }
        }
    }
}
