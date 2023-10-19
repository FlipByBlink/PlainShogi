import SwiftUI

enum 画像書き出し {
    static let 一時ファイルURL: URL = .cachesDirectory.appending(component: "image.png")
    static let ファイル名: String = {
        .init(localized: "☖ Plain将棋盤 ")
        + Date.now.formatted(.dateTime.year().month().day())
        + ".png"
    }()
    @MainActor
    static func 画像として保存(_ モデル: アプリモデル) {
        let レンダラー = ImageRenderer(content: {
            将棋View()
                .environmentObject(モデル)
                .frame(width: 300, height: 300)
                .padding()
                .background { Color.white }
        }())
        レンダラー.scale = 3
        guard let データ = レンダラー.uiImage?.pngData() else {
            assertionFailure()
            return
        }
        do {
            try データ.write(to: Self.一時ファイルURL)
        } catch {
            assertionFailure()
            return
        }
    }
    static func 画像を取得() -> Image? {
        if let データ = try? Data(contentsOf: Self.一時ファイルURL),
           let uiImage = UIImage(data: データ) {
            Image(uiImage: uiImage)
        } else {
            nil
        }
    }
    @MainActor
    static func サムネイルを取得(_ モデル: アプリモデル) -> Image {
        let レンダラー = ImageRenderer(content: {
            将棋View()
                .environmentObject(モデル)
                .frame(width: 200, height: 200)
                .padding(4)
                .background { Color.white }
                .fontWeight(.semibold)
        }())
        guard let uiImage = レンダラー.uiImage else {
            assertionFailure()
            return .init(.roundedIcon)
        }
        return .init(uiImage: uiImage)
    }
}
