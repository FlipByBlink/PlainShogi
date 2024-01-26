import SwiftUI

struct SharePlayガイドメニュー: View {
    @EnvironmentObject var モデル: アプリモデル
    private var SharePlay中: Bool {
        [.waiting, .joined].contains(モデル.グループセッション?.state)
    }
    var body: some View {
        List {
            if !self.SharePlay中 {
                self.事前準備完セクション()
                self.アクティビティ参加誘導セクション()
                self.アクティビティ起動誘導セクション()
            }
            self.ステータスセクション()
            self.離脱ボタンや終了ボタン()
            Section { SharePlay紹介メニューリンク() }
        }
        .animation(.default, value: self.SharePlay中)
        .navigationTitle("将棋盤をSharePlay")
    }
    private func 事前準備完セクション() -> some View {
        Section {
            Text("現在、友達と繋がっているようです。友達が立ち上げたアクティビティに参加するか、もしくは自分でアクティビティを起動しましょう。")
                .padding(8)
        } header: {
            Text("事前準備完了")
        }
    }
    private func アクティビティ参加誘導セクション() -> some View {
        Section {
            Text("友達が既に「将棋盤」アクティビティを起動している場合は、システム側のUIを操作してアクティビティに参加しましょう。")
                .padding(8)
            Image("joinFromBanner")
                .resizable()
                .scaledToFit()
                .border(.black)
                .frame(maxWidth: .infinity, maxHeight: 180)
        } header: {
            Text("SharePlayに参加する")
                .textCase(.none)
        }
    }
    private func アクティビティ起動誘導セクション() -> some View {
        Section {
            Text("自分からSharePlayを開始する事もできます。アクティビティを起動したら友達にSharePlay参加を促しましょう。")
                .padding(8)
            Button {
                🄶roupActivity.アクティビティを起動する()
                モデル.表示中のシート = nil
            } label: {
                Label("アクティビティ「将棋盤」を起動する", systemImage: "power")
                    .font(.body.weight(.medium))
                    .padding(.vertical, 4)
            }
            .disabled(モデル.グループセッション != nil)
        } header: {
            Text("自分からSharePlayを開始する")
                .textCase(.none)
        }
    }
    @State private var 終了確認ダイアログ表示: Bool = false
    private func 離脱ボタンや終了ボタン() -> some View {
        Group {
            if self.SharePlay中 {
                Section {
                    Button {
                        モデル.グループセッション?.leave()
                        システムフィードバック.警告()
                        モデル.表示中のシート = nil
                    } label: {
                        Label("アクティビティから離脱する", systemImage: "escape")
                    }
                } footer: {
                    Text("アクティビティから離脱しても、自分以外はアクティビティに参加したままです。")
                }
                Section {
                    Button {
                        self.終了確認ダイアログ表示 = true
                        システムフィードバック.軽め()
                    } label: {
                        Label("アクティビティを終了する", systemImage: "power.dotted")
                    }
                } footer: {
                    Text("アクティビティを終了すると、全員がアクティビティから離脱します。")
                }
                .confirmationDialog("アクティビティを終了しますか？",
                                    isPresented: self.$終了確認ダイアログ表示,
                                    titleVisibility: .visible) {
                    Button(role: .destructive) {
                        モデル.グループセッション?.end()
                        システムフィードバック.エラー()
                        モデル.表示中のシート = nil
                    } label: {
                        Label("はい、アクティビティを終了します", systemImage: "power.dotted")
                    }
                } message: {
                    Text("アクティビティを終了すると、全員がアクティビティから離脱します。")
                }
            }
        }
    }
    private func ステータスセクション() -> some View {
        Group {
            if モデル.グループセッション != nil {
                Section {
                    Label("アクティビティ", systemImage: "power")
                        .badge(モデル.セッションステート表記)
                    Label("現在の参加者数", systemImage: "person.3")
                        .badge(モデル.参加人数?.description)
                } header: {
                    Text("状況")
                }
            }
        }
    }
}
