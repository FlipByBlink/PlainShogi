import Foundation
import SwiftUI

let ℹ️appName: LocalizedStringKey = "Plain将棋盤"
let ℹ️appSubTitle: LocalizedStringKey = "iPhone / iPad / Apple Watch / Mac / Apple TV"

let 📜versionInfos = 📜VersionInfo.history(("1.3", "2023-01-22"),
                                           ("1.2.2", "2022-08-18"),
                                           ("1.2.1", "2022-07-21"),
                                           ("1.2", "2022-07-09"),
                                           ("1.1", "2022-05-07"),
                                           ("1.0", "2022-04-21")) //降順。先頭の方が新しい

let 🔗appStoreProductURL = URL(string: "https://apps.apple.com/app/id1620268476")!

let 👤privacyPolicyDescription = """
2022-04-21

### Japanese
このアプリ自身において、ユーザーの情報を一切収集しません。

### English
This application don't collect user infomation.
"""

let 🔗webRepositoryURL = URL(string: "https://github.com/FlipByBlink/PlainShogi")!
let 🔗webMirrorRepositoryURL = URL(string: "https://gitlab.com/FlipByBlink/PlainShogi_Mirror")!

enum 📁SourceCodeCategory: String, CaseIterable, Identifiable {
    case main, Shared, Sub, Others, WatchApp, WatchComplication
    var id: Self { self }
    var fileNames: [String] {
        switch self {
            case .main:
                return ["Plain将棋盤App.swift",
                        "📱AppModel.swift",
                        "ContentView.swift"]
            case .Shared:
                return []
            case .Sub:
                return ["☖ShogiView.swift",
                        "☖ShogiModel.swift",
                        "🛠AppMenu.swift",
                        "📬DropDelegate.swift",
                        "🪄EditMode.swift",
                        "📜History.swift",
                        "👥SharePlay.swift",
                        "💾Data.swift",
                        "📣ADContent.swift",
                        "📃TextImportExport.swift",
                        "💥Feedback.swift",
                        "🗄️Rest.swift"]
            case .Others:
                return ["🧰MetaData.swift",
                        "ℹ️AboutApp.swift",
                        "📣AD.swift",
                        "🛒InAppPurchase.swift"]
            case .WatchApp:
                return []
            case .WatchComplication:
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
