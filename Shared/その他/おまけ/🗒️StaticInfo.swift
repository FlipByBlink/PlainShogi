import SwiftUI

enum 🗒️StaticInfo {
    static let appName: LocalizedStringKey = "Plain将棋盤"
    static let appSubTitle: LocalizedStringKey = "iPhone / iPad / Apple Watch / Mac / Apple TV"
    
    static let appStoreProductURL = URL(string: "https://apps.apple.com/app/id1620268476")!
    static var appStoreUserReviewURL: URL { .init(string: "\(Self.appStoreProductURL)?action=write-review")! }
    
    static var contactAddress: String { "sear_pandora_0x@icloud.com" }
    
    static let privacyPolicyDescription = """
        2022-04-21
        
        
        日本語(Japanese)
        
        このアプリ自身において、ユーザーの情報を一切収集しません。
        
        
        English
        
        This application don't collect user infomation.
        """
    
    static let webRepositoryURL = URL(string: "https://github.com/FlipByBlink/PlainShogi")!
    static let webMirrorRepositoryURL = URL(string: "https://gitlab.com/FlipByBlink/PlainShogi_Mirror")!
}

#if os(iOS)
extension 🗒️StaticInfo {
    static let versionInfos: [(version: String, date: String)] = [("1.5", "2023-10-24(仮)"),
                                                                  ("1.4", "2023-05-11"),
                                                                  ("1.3", "2023-01-22"),
                                                                  ("1.2.2", "2022-08-18"),
                                                                  ("1.2.1", "2022-07-21"),
                                                                  ("1.2", "2022-07-09"),
                                                                  ("1.1", "2022-05-07"),
                                                                  ("1.0", "2022-04-21")] //降順。先頭の方が新しい
    
    enum SourceCodeCategory: String, CaseIterable, Identifiable {
        case main, その他
        var id: Self { self }
        var fileNames: [String] {
            switch self {
                case .main: ["App.swift",
                             "ContentView.swift",
                             "📱AppModel.swift"]
                case .その他: ["🪧Sheet.swift",
                             "📣ADContent.swift",
                             "💬RequestUserReview.swift",
                             "🩹Workaround.swift",
                             "🗒️StaticInfo.swift",
                             "ℹ️AboutApp.swift",
                             "📣ADModel.swift",
                             "📣ADComponents.swift",
                             "🛒InAppPurchaseModel.swift",
                             "🛒InAppPurchaseView.swift"]
            }
        }
    }
}

#elseif os(watchOS)
extension 🗒️StaticInfo {
    enum SourceCodeCategory: String, CaseIterable, Identifiable {
        case main, その他, Widget
        var id: Self { self }
        var fileNames: [String] {
            switch self {
                case .main: ["App.swift",
                             "ContentView.swift",
                             "📱AppModel.swift"]
                case .その他: ["🗒️StaticInfo.swift",
                             "ℹ️AboutApp.swift"]
                case .Widget: ["Widget.swift"]
            }
        }
    }
}

#elseif os(macOS)
extension 🗒️StaticInfo {
    static let versionInfos: [(version: String, date: String)] = [("1.1", "2021-03-01"),
                                                                  ("1.0.1", "2021-02-01"),
                                                                  ("1.0", "2021-01-01")] //降順。先頭の方が新しい
    
    enum SourceCodeCategory: String, CaseIterable, Identifiable {
        case main, その他
        var id: Self { self }
        var fileNames: [String] {
            switch self {
                case .main: ["App.swift",
                             "ContentView.swift",
                             "📱AppModel.swift",
                             "📱AppModel(extension).swift"]
                case .その他: ["📣ADSheet.swift",
                             "🔧Settings.swift",
                             "🪄Commands.swift",
                             "💬RequestUserReview.swift",
                             "🗒️StaticInfo.swift",
                             "ℹ️HelpWindows.swift",
                             "ℹ️HelpCommands.swift",
                             "📣ADModel.swift",
                             "📣ADContent.swift",
                             "🛒InAppPurchaseModel.swift",
                             "🛒InAppPurchaseWindow.swift",
                             "🛒InAppPurchaseMenu.swift",
                             "🛒InAppPurchaseCommand.swift"]
            }
        }
    }
}
#endif
