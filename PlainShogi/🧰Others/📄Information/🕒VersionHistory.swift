
import SwiftUI

struct 🕒VersionHistoryLink: View {
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
- 盤面の駒を盤外へ直接移動できるように変更
- 簡単に駒を消したり増やしたりする機能の追加
- 初期化等のショートカットをメニューボタン長押しで呼び出す機能を追加
- 手駒を3回タップして消す機能の削除
- アプリ内課金で広告非表示にできる機能を実装
- アプリ内広告バナーの表示頻度を「3回起動毎に起動直後1回」から「起動6回以降は起動直後毎回」に変更
- 広くリファクタリング
- いくつかの小さめの改善やバグ修正
==== English ====
- Directly move a piece to out-of-board
- Add Edit Mode
- Add shortcut function by long press menu button
- Delete function to delete a piece by 3 tapping
- Add In-App Purchase to hide AD
- Change frequency in AD ("1 in 3" → "after 5, every")
- Widely refactoring
- Various bugfixes and improvements
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
