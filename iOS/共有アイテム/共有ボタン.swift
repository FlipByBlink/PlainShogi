import SwiftUI
import GroupActivities

struct 共有ボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    @AppStorage("セリフ体") var セリフ体オプション: Bool = false
    @AppStorage("太字") var 太字オプション: Bool = false
    @AppStorage("サイズ") var サイズオプション: 字体.サイズ = .標準
    @State private var 現在の盤面を画像として保存: Bool = false
    @State private var サムネイル: Image = .init(.roundedIcon)
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
        .task(priority: .background) { self.画像保存をリクエスト() }
        .onChange(of: self.モデル.局面) { _ in self.画像保存をリクエスト() }
        .onChange(of: self.モデル.上下反転) { _ in self.画像保存をリクエスト() }
        .onChange(of: self.モデル.english表記) { _ in self.画像保存をリクエスト() }
        .onChange(of: self.モデル.直近操作強調表示機能オフ) { _ in self.画像保存をリクエスト() }
        .onChange(of: self.セリフ体オプション) { _ in self.画像保存をリクエスト() }
        .onChange(of: self.太字オプション) { _ in self.画像保存をリクエスト() }
        .onChange(of: self.サイズオプション) { _ in self.画像保存をリクエスト() }
        .onChange(of: self.現在の盤面を画像として保存) {
            if $0 {
                self.画像保存を実行()
                self.現在の盤面を画像として保存 = false
            }
        }
#endif
    }
}

private extension 共有ボタン {
    private func 画像保存をリクエスト() {
        Task(priority: .background) {
            try? await Task.sleep(for: .seconds(1))
            self.現在の盤面を画像として保存 = true
        }
    }
    private func 画像保存を実行() {
        画像書き出し.画像として保存(self.モデル)
        self.サムネイル = 画像書き出し.サムネイルを取得(self.モデル)
    }
    private func ボタンアイコン() -> some View {
        Image(systemName: "square.and.arrow.up")
            .font(.title3.weight(.light))
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(8)
            .foregroundStyle(.foreground)
    }
    private enum アイテム {
        @available(iOS 17, *)
        struct IOS17向け: Transferable {
            static var transferRepresentation: some TransferRepresentation {
                DataRepresentation(exportedContentType: .png) { _ in
                    try .init(contentsOf: 画像書き出し.一時ファイルURL)
                }
                .suggestedFileName(画像書き出し.ファイル名)
                GroupActivityTransferRepresentation { _ in 🄶roupActivity() }
            }
        }
        struct IOS16向け: Transferable {
            static var transferRepresentation: some TransferRepresentation {
                DataRepresentation(exportedContentType: .png) { _ in
                    try .init(contentsOf: 画像書き出し.一時ファイルURL)
                }
                .suggestedFileName(画像書き出し.ファイル名)
            }
        }
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

//private var メッセージ: Text {
//    .init("""
//    \(self.モデル.現在の盤面をテキストに変換する())
//
//    「Plain将棋盤」より
//    https://apple.co/3BaZcSa
//    """)
//}
