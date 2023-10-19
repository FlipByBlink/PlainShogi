import SwiftUI
import GroupActivities

enum 共有アイテム {
    @available(iOS 17, *)
    struct IOS17向け: Transferable {
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(exportedContentType: .png) { _ in
                try .init(contentsOf: 共有アイテム.一時ファイルURL)
            }
            .suggestedFileName(共有アイテム.ファイル名)
            GroupActivityTransferRepresentation { _ in 🄶roupActivity() }
        }
    }
    struct IOS16向け: Transferable {
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(exportedContentType: .png) { _ in
                try .init(contentsOf: 共有アイテム.一時ファイルURL)
            }
            .suggestedFileName(共有アイテム.ファイル名)
        }
    }
    static let 一時ファイルURL: URL = .temporaryDirectory.appending(component: "image.png")
    static var ファイル名: String {
        .init(localized: "☖ Plain将棋盤 ")
        + Date.now.formatted(.dateTime.year().month().day())
        + ".png"
    }
}

struct 共有ボタン: View {
    @EnvironmentObject var モデル: アプリモデル
    @AppStorage("セリフ体") var セリフ体オプション: Bool = false
    @AppStorage("太字") var 太字オプション: Bool = false
    @AppStorage("サイズ") var サイズオプション: 字体.サイズ = .標準
    @State private var 現在の盤面を画像として保存: Bool = false
    @State private var サムネイルイメージ: UIImage?
    var body: some View {
        Group {
            if #available(iOS 17, *) {
                ShareLink(item: 共有アイテム.IOS17向け(),
                          message: .init(self.モデル.現在の盤面をテキストに変換する()),
                          preview: .init("盤面を共有",
                                         icon: self.サムネイルアイコン)) {
                    self.ボタンアイコン()
                }
            } else {
                ShareLink(item: 共有アイテム.IOS16向け(),
                          message: .init(self.モデル.現在の盤面をテキストに変換する()),
                          preview: .init("盤面を共有",
                                         image: self.サムネイルアイコン)) {
                    self.ボタンアイコン()
                }
            }
        }
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
    }
    private func 画像保存をリクエスト() {
        Task(priority: .background) {
            try? await Task.sleep(for: .seconds(3))
            self.現在の盤面を画像として保存 = true
        }
    }
    private func 画像保存を実行() {
        let renderer = ImageRenderer(content: self.書き出しView)
        renderer.scale = 3
        try? renderer.uiImage?.pngData()?.write(to: 共有アイテム.一時ファイルURL)
        self.サムネイルイメージ = ImageRenderer(content: self.サムネイルView).uiImage
    }
    private var 書き出しView: some View {
        将棋View()
            .environmentObject(self.モデル)
            .frame(width: 300, height: 300)
            .padding()
            .background { Color.white }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    private var サムネイルView: some View {
        将棋View()
            .environmentObject(self.モデル)
            .frame(width: 200, height: 200)
            .padding(4)
            .background { Color.white }
            .fontWeight(.semibold)
    }
    private func ボタンアイコン() -> some View {
        Image(systemName: "square.and.arrow.up")
            .font(.title3.weight(.light))
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .padding(8)
            .padding(.leading)
            .foregroundStyle(.foreground)
    }
    private var サムネイルアイコン: Image {
        .init(uiImage: self.サムネイルイメージ ?? .roundedIcon)
    }
    //private var メッセージ: Text {
    //    .init("""
    //    \(self.モデル.現在の盤面をテキストに変換する())
    //
    //    「Plain将棋盤」より
    //    https://apple.co/3BaZcSa
    //    """)
    //}
}
