import SwiftUI
import GroupActivities

struct メニュートップ: View {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        List {
            Self.SharePlay誘導セクション()
#if !targetEnvironment(macCatalyst)
            Section {
                盤面初期化ボタン()
                一手戻すボタン()
                増減モード開始ボタン(タイトル: "駒を消したり増やしたりする")
                強調表示クリアボタン()
            } header: {
                Text("編集")
            }
            Section {
                self.上下反転Toggle()
                見た目カスタマイズメニューリンク()
            } header: {
                if self.groupStateObserver.isEligibleForGroupSession {
                    Text("オプション(共有相手との同期なし)")
                } else {
                    Text("オプション")
                }
            }
            Section {
                NavigationLink {
                    ブックマークメニュー()
                } label: {
                    Label("ブックマーク", systemImage: "bookmark")
                }
                NavigationLink {
                    履歴メニュー()
                } label: {
                    Label("履歴", systemImage: "clock")
                }
                .disabled(局面モデル.履歴.isEmpty)
            }
#endif
            Section {
                共有メニューリンク()
                SharePlay紹介メニューリンク()
            }
            Section {
                Self.細かな使い方リンク()
                不具合フィードバックリンク()
            }
            Self.アプリについてセクション()
            🛒InAppPurchaseMenuLink()
        }
        .navigationTitle("メニュー")
        .animation(.default, value: self.groupStateObserver.isEligibleForGroupSession)
    }
}

private extension メニュートップ {
    private func 上下反転Toggle() -> some View {
        Toggle(isOn: $モデル.上下反転) {
            Label("上下反転", systemImage: "arrow.up.arrow.down")
        }
    }
    private struct SharePlay誘導セクション: View {
        @EnvironmentObject var モデル: アプリモデル
        @StateObject private var groupStateObserver = GroupStateObserver()
        var body: some View {
            if self.groupStateObserver.isEligibleForGroupSession {
                Section {
                    NavigationLink {
                        SharePlayガイドメニュー()
                    } label: {
                        Label("将棋盤をSharePlay", systemImage: "shareplay")
                    }
                }
            }
        }
    }
    private struct 細かな使い方リンク: View {
        var body: some View {
            NavigationLink {
                List {
                    Label("長押しして駒を持ち上げ、そのままスライドして移動させる",
                          systemImage: "hand.draw")
                    Section {
                        Label("iCloudによって端末間でデータ(局面/履歴/ブックマーク)が同期されます",
                              systemImage: "icloud")
                    } footer: {
                        Text("iCloud同期は簡易的な用途を想定しています。「同時に起動している端末間での同期」といったリアルタイム性の高い用途は想定していません。")
                    }
                    Self.メニューショートカットセクション()
                    Self.共有ショートカットセクション()
                }
                .navigationTitle("細かな使い方")
            } label: {
                Label("細かな使い方", systemImage: "magazine")
            }
        }
        private static func メニューショートカットセクション() -> some View {
            Section {
#if !targetEnvironment(macCatalyst)
                VStack {
                    Label("メニューボタンを長押しすると「初期化ボタン」や「一手戻すボタン」などを呼び出せます",
                          systemImage: "gearshape")
                    Image("MenuLongPress")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .border(.black)
                        .padding(8)
                }
                .padding(.vertical, 8)
#endif
            }
        }
        private static func 共有ショートカットセクション() -> some View {
            Section {
#if !targetEnvironment(macCatalyst)
                VStack {
                    Label("共有ボタンを長押しするとフォーマットを指定できます",
                          systemImage: "gearshape")
                    Image("MenuLongPress")//TODO: 実装
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .border(.black)
                        .padding(8)
                }
                .padding(.vertical, 8)
#endif
            }
        }
    }
    private static func アプリについてセクション() -> some View {
        Section {
            ℹ️IconAndName()
            ℹ️AppStoreLink()
            NavigationLink {
                List { ℹ️AboutAppContent() }
                    .navigationTitle(String(localized: "About App", table: "🌐AboutApp"))
            } label: {
                Label(String(localized: "About App", table: "🌐AboutApp"),
                      systemImage: "doc")
            }
        }
    }
}
