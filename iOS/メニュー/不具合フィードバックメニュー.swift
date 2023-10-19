import SwiftUI

struct 不具合フィードバックリンク: View {
    var body: some View {
        NavigationLink {
            Self.メニュー()
        } label: {
            Label("不具合フィードバック", systemImage: "ladybug")
        }
    }
    private struct メニュー: View {
        @Environment(\.locale) var locale
        private var 日本語環境: Bool { self.locale.language.languageCode == .japanese }
        private static var アドレス: String = "sear_pandora_0x@icloud.com"
        private var ボタンURL: URL {
            var 値 = "mailto:" + Self.アドレス
            let タイトル: String
            if self.日本語環境 {
                タイトル = "☖ Plain将棋盤 不具合フィードバック 🐞"
            } else {
                タイトル = "☖ PlainShogiBoard bug feedback 🐞"
            }
            値 += "?subject="
            値 += タイトル.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            if self.日本語環境 {
                値 += "&body="
                値 += "ここに入力してください".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            } else {
                値 += "&body=Input%20here"
            }
            return URL(string: 値)!
        }
        var body: some View {
            List {
                Section {
                    Label("もし、このアプリでバグやクラッシュが発生した場合、以下のボタン(もしくはアドレス)からフィードバックを送るとアプリの改善に繋がります",
                          systemImage: "ladybug")
                    Label("特にSharePlay中に発生した不具合について報告していただけるととても助かります",
                          systemImage: "shareplay")
                }
                Link(destination: self.ボタンURL) {
                    Label("メールアプリからフィードバックを送る", systemImage: "envelope")
                }
                .badge(Text(Image(systemName: "arrow.up.forward.app")))
                HStack {
                    Label(Self.アドレス, systemImage: "link")
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("コピー") {
                        UIPasteboard.general.string = Self.アドレス
                        フィードバック.軽め()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("不具合フィードバック")
        }
    }
}
