import SwiftUI
import GroupActivities

struct メイン画面の共有ボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    @Binding var サムネイル: Image
    var body: some View {
#if !targetEnvironment(macCatalyst)
        Group {
            if #available(iOS 17, *) {
                ShareLink(item: Self.アイテム.IOS17向け(),
                          message: .init(self.モデル.現在の盤面をテキストに変換する()),
                          preview: .init("盤面を共有", icon: self.サムネイル),
                          label: self.ボタンアイコン)
            } else {
                ShareLink(item: Self.アイテム.IOS16向け(),
                          message: .init(self.モデル.現在の盤面をテキストに変換する()),
                          preview: .init("盤面を共有", icon: self.サムネイル),
                          label: self.ボタンアイコン)
            }
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12))
        .contextMenu { self.サブボタンズ() }
        .padding(.leading)
#endif
    }
    init(_ サムネイル: Binding<Image>) {
        self._サムネイル = サムネイル
    }
}

private extension メイン画面の共有ボタン {
    private enum アイテム {
        @available(iOS 17, *)
        struct IOS17向け: Transferable {
            static var transferRepresentation: some TransferRepresentation {
                FileRepresentation(exportedContentType: .png) { _ in
                    SentTransferredFile(画像書き出し.一時ファイルURL)
                }
                .suggestedFileName(画像書き出し.ファイル名)
                GroupActivityTransferRepresentation { _ in 🄶roupActivity() }
                ProxyRepresentation { _ in
                    if let uiImage = UIImage(data: try .init(contentsOf: 画像書き出し.一時ファイルURL)) {
                        Image(uiImage: uiImage)
                    } else {
                        throw 不特定エラー.要修正
                    }
                }
            }
        }
        struct IOS16向け: Transferable {
            static var transferRepresentation: some TransferRepresentation {
                FileRepresentation(exportedContentType: .png) { _ in
                    SentTransferredFile(画像書き出し.一時ファイルURL)
                }
                .suggestedFileName(画像書き出し.ファイル名)
                ProxyRepresentation { _ in
                    if let uiImage = UIImage(data: try .init(contentsOf: 画像書き出し.一時ファイルURL)) {
                        Image(uiImage: uiImage)
                    } else {
                        throw 不特定エラー.要修正
                    }
                }
            }
        }
    }
    private func ボタンアイコン() -> some View {
        Image(systemName: "square.and.arrow.up")
            .font(.title3.weight(.light))
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(8)
            .foregroundStyle(.foreground)
    }
    private func サブボタンズ() -> some View {
        Section {
            Button {
                self.モデル.表示中のシート = .テキスト共有
            } label: {
                Label("テキストとして共有", systemImage: "square.and.arrow.up")
            }
            Button {
                self.モデル.表示中のシート = .画像共有
            } label: {
                Label("画像として共有", systemImage: "square.and.arrow.up")
            }
        } header: {
            Text("フォーマットを指定")
        }
    }
}
