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
                .frame(width: 300, height: 300)
                .padding()
                .background { Color.white }
        }())
        レンダラー.scale = 3
        guard let データ = レンダラー.uiImage?.pngData() else {
            assertionFailure()
            return
        }
        Task(priority: .low) {
            do {
                try データ.write(to: Self.一時ファイルURL)
            } catch {
                print(error)
            }
        }
    }
    static func 画像を取得() throws -> Image {
        if let uiImage = UIImage(data: try Data(contentsOf: Self.一時ファイルURL)) {
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
            return .init(.roundedIcon)
        }
        return .init(uiImage: uiImage)
    }
}

//struct 共有画像モデル {
//    var pngデータ: Data
//    @MainActor
//    static func 生成(_ モデル: アプリモデル) -> Self {
//        let レンダラー = ImageRenderer(content: {
//            将棋View()
//                .environmentObject(モデル)
//                .frame(width: 300, height: 300)
//                .padding()
//                .background { Color.white }
//        }())
//        レンダラー.scale = 3
//        guard let データ = レンダラー.uiImage?.pngData() else {
//            assertionFailure()
//            return Self(pngデータ: .init())
//        }
//        return Self(pngデータ: データ)
//    }
//    var uiImage: UIImage {
//        if let 値 = UIImage(data: self.pngデータ) {
//            return 値
//        } else {
//            assertionFailure()
//            return .init(resource: .roundedIcon)
//        }
//    }
//    var image: Image { .init(uiImage: self.uiImage) }
//    static var プレースホルダー: Self {
//        .init(pngデータ: UIImage(resource: .roundedIcon).pngData() ?? .init())
//    }
//    static var ファイル名: String {
//        .init(localized: "☖ Plain将棋盤 ")
//        + Date.now.formatted(.dateTime.year().month().day())
//        + ".png"
//    }
//}
