import SwiftUI
import GroupActivities

struct メイン画面の共有ボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    @Binding var サムネイル: Image
    var body: some View {
#if !targetEnvironment(macCatalyst)
        Group {
            if #available(iOS 17, *), モデル.グループセッション == nil {
                self.アクティビティありShareLink()
            } else {
                self.アクティビティなしShareLink()
            }
        }
        .contextMenu { self.サブボタンズ() }
        .modifier(Self.IOS向け装飾())
#endif
    }
    init(_ サムネイル: Binding<Image>) {
        self._サムネイル = サムネイル
    }
}

private extension メイン画面の共有ボタン {
    @available(iOS 17, *)
    private func アクティビティありShareLink() -> some View {
        ShareLink(item: Self.アイテム.アクティビティあり(),
                  message: .init(self.モデル.現在の盤面をテキストに変換する()),
                  preview: .init("盤面を共有", icon: self.サムネイル),
                  label: self.ボタンアイコン)
    }
    private func アクティビティなしShareLink() -> some View {
        ShareLink(item: Self.アイテム.アクティビティなし(),
                  message: .init(self.モデル.現在の盤面をテキストに変換する()),
                  preview: .init("盤面を共有", icon: self.サムネイル),
                  label: self.ボタンアイコン)
    }
    private enum アイテム {
        @available(iOS 17, *)
        struct アクティビティあり: Transferable {
            static var transferRepresentation: some TransferRepresentation {
                FileRepresentation(exportedContentType: .png) { _ in
                    SentTransferredFile(画像書き出し.一時ファイルURL)
                }
                .suggestedFileName(画像書き出し.ファイル名)
                GroupActivityTransferRepresentation { _ in 🄶roupActivity() }
                ProxyRepresentation { _ in try アイテム.プロキシ用のImage取得() }
            }
        }
        struct アクティビティなし: Transferable {
            static var transferRepresentation: some TransferRepresentation {
                FileRepresentation(exportedContentType: .png) { _ in
                    SentTransferredFile(画像書き出し.一時ファイルURL)
                }
                .suggestedFileName(画像書き出し.ファイル名)
                ProxyRepresentation { _ in try アイテム.プロキシ用のImage取得() }
            }
        }
        static func プロキシ用のImage取得() throws -> Image {
            if let uiImage = UIImage(data: try .init(contentsOf: 画像書き出し.一時ファイルURL)) {
                Image(uiImage: uiImage)
            } else {
                throw 不特定エラー.要修正
            }
        }
    }
    private func ボタンアイコン() -> some View {
        Image(systemName: "square.and.arrow.up")
#if os(iOS)
            .font(.title3.weight(.light))
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(8)
            .foregroundStyle(.foreground)
#endif
    }
    private struct IOS向け装飾: ViewModifier {
        func body(content: Content) -> some View {
#if os(iOS)
            content
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12))
                .hoverEffect(.highlight)
                .padding(.leading)
#else
            content
#endif
        }
    }
    private func サブボタンズ() -> some View {
        Section {
            Button {
                self.モデル.表示中のシート = .テキスト共有
            } label: {
                Label("テキストとして共有", systemImage: "text.justify.left")
            }
            Button {
                self.モデル.表示中のシート = .画像共有
            } label: {
                Label("画像として共有", systemImage: "photo")
            }
            Divider()
            ShareLink(item: 🗒️StaticInfo.appStoreProductURL) {
                Label("アプリのリンクを共有", systemImage: "link")
            }
        } header: {
            Text("フォーマットを指定")
        }
    }
}
