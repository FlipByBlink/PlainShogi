import SwiftUI

let ℹ️appName: LocalizedStringKey = "Plain将棋盤"
let ℹ️appSubTitle: LocalizedStringKey = "iPhone / iPad / Apple Watch / Mac / Apple TV"

let 📜versionInfos = 📜VersionInfo.history(("1.4", "2023-05-01"),
                                           ("1.3", "2023-01-22"),
                                           ("1.2.2", "2022-08-18"),
                                           ("1.2.1", "2022-07-21"),
                                           ("1.2", "2022-07-09"),
                                           ("1.1", "2022-05-07"),
                                           ("1.0", "2022-04-21")) //降順。先頭の方が新しい

let 🔗appStoreProductURL = URL(string: "https://apps.apple.com/app/id1620268476")!

let 👤privacyPolicyDescription = """
2022-04-21


日本語(Japanese)

このアプリ自身において、ユーザーの情報を一切収集しません。


English

This application don't collect user infomation.
"""

let 🔗webRepositoryURL = URL(string: "https://github.com/FlipByBlink/PlainShogi")!
let 🔗webMirrorRepositoryURL = URL(string: "https://gitlab.com/FlipByBlink/PlainShogi_Mirror")!

enum 📁SourceCodeCategory: String, CaseIterable, Identifiable {
    case main, Shared, Sub, Others, WatchApp, WatchComplication, tvApp
    var id: Self { self }
    var fileNames: [String] {
        switch self {
            case .main:
                return ["Plain将棋盤App.swift",
                        "ContentView.swift"]
            case .Shared:
                return [  "☖ShogiModel.swift",
                          "📱AppModel.swift",
                          "🔠Font.swift",
                          "💾Data.swift",
                          "💥Feedback.swift"]
            case .Sub:
                return ["☖ShogiView.swift",
                        "🛠AppMenu.swift",
                        "🪧Sheet.swift",
                        "📬DropDelegate.swift",
                        "🪄EditMode.swift",
                        "📜History.swift",
                        "👥SharePlay.swift",
                        "📣ADContent.swift",
                        "📃TextImportExport.swift",
                        "🗄️Rest.swift"]
            case .Others:
                return ["🧰MetaData.swift",
                        "ℹ️AboutApp.swift",
                        "📣AD.swift",
                        "🛒InAppPurchase.swift"]
            case .WatchApp:
                return ["PS Watch App.swift",
                        "ContentView_watchOSApp.swift",
                        "☖ShogiView_watchOSApp.swift",
                        "🛠OptionMenu.swift"]
            case .WatchComplication:
                return ["PSComplication.swift"]
            case .tvApp:
                return []
        }
    }
}

struct 📜VersionInfo: Identifiable {
    var number: String
    var date: String
    var id: String { self.number }
    static func history(_ ⓘnfos: (ⓝumber: String, ⓓate: String) ...) -> [Self] {
        ⓘnfos.map { Self(number: $0.ⓝumber, date: $0.ⓓate) }
    }
}
