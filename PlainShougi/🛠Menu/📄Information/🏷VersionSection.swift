
import SwiftUI

struct 🏷VersionSection: View {
    var body: some View {
        Section {
            NavigationLink {
                ScrollView {
                    Text(🕒VersionHistory)
                        .padding()
                }
                .navigationBarTitle("Version History")
                .navigationBarTitleDisplayMode(.inline)
                .textSelection(.enabled)
            } label: {
                Label(🕒LatestVersionNumber, systemImage: "signpost.left")
            }
            .accessibilityLabel("Version History")
        } header: {
            Text("Version")
        } footer: {
            let 📅 = Date.now.formatted(date: .numeric, time: .omitted)
            Text("builded on \(📅)")
        }
    }
}


let 🕒LatestVersionNumber = "1.2"

let 🕒LatestVersionDescription = """
- ああああ
==== English ====
- AAAA
"""

var 🕒VersionHistory: String {
    var 📃 = "🕒 Version " + 🕒LatestVersionNumber + " : "
    📃 += "(builded on " + Date.now.formatted(date: .numeric, time: .omitted) + ")\n"
    📃 += 🕒LatestVersionDescription + "\n\n\n"
    📃 += 🕒PastVersionHistory
    return 📃
}

let 🕒PastVersionHistory = """
🕒 Version 1.1 : 2022-05-7
駒を英語表記に変更する機能を追加
プレーンテキスト書き出し/読み込み機能を追加
ソースコードをアプリ内で確認する機能を追加
セルフ広告バナーを追加
枠線を非表示するオプションを削除
その他、細かな改善をいくつか実施
==== English ====
Add english term option
Add plain text export/import function
Add function to check source code in app
Add self-AD banner
Delete option to hide edge line
Small fix/improve


🕒 Version 1.0 : 2022-04-21
Initial release
"""
