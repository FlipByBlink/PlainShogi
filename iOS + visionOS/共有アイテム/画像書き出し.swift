import SwiftUI

enum 画像書き出し {
    static let 一時ファイルURL: URL = .cachesDirectory.appending(component: "image.png")
    static let ファイル名: String = {
        .init(localized: "☖ Plain将棋盤 ")
        + Date.now.formatted(.dateTime.year().month().day())
        + ".png"
    }()
    @MainActor
    static func 保存(_ モデル: アプリモデル) {
        let レンダラー = ImageRenderer(content: {
            将棋View()
                .environmentObject(モデル)
                .frame(width: 440, height: 440)
                .padding()
                .background { Color.white }
        }())
        レンダラー.scale = 2
        guard let データ = レンダラー.uiImage?.pngData() else {
            assertionFailure()
            return
        }
        Task(priority: .low) {
            do {
                if FileManager.default.fileExists(atPath: Self.一時ファイルURL.path()) {
                    try FileManager.default.removeItem(at: Self.一時ファイルURL)
                }
                try データ.write(to: Self.一時ファイルURL)
            } catch {
                assertionFailure()
                print(error)
            }
        }
    }
    static func 画像を取得() throws -> Image {
        if let uiImage = UIImage(data: try .init(contentsOf: Self.一時ファイルURL)) {
            .init(uiImage: uiImage)
        } else {
            throw Self.エラー.画像取得失敗
        }
    }
    private enum エラー: Error {
        case 画像取得失敗
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
            return .init(.aboutAppIcon)
        }
        return .init(uiImage: uiImage)
    }
}
