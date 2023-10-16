import SwiftUI
import GroupActivities
import UIKit

struct SharePlay環境構築: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject private var groupStateObserver = GroupStateObserver()
    func body(content: Content) -> some View {
        content
            .animation(.default, value: self.groupStateObserver.isEligibleForGroupSession)
            .animation(.default, value: モデル.グループセッション?.state)
            .task { await モデル.新規GroupSessionを受信したら設定する() }
            .modifier(Self.参加完了通知バナー())
            .modifier(Self.SharePlay設定未完了ローディング())
    }
    private struct SharePlay設定未完了ローディング: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        func body(content: Content) -> some View {
            content
                .overlay {
                    if モデル.グループセッション != nil, モデル.局面.駒が1つも無い {
                        ProgressView()
                    }
                }
        }
    }
    private struct 参加完了通知バナー: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        @State private var 参加完了バナーを表示: Bool = false
        func body(content: Content) -> some View {
            content
                .onChange(of: モデル.グループセッション != nil) {
                    if $0 {
                        withAnimation(.default.speed(2)) {
                            self.参加完了バナーを表示 = true
                        }
                    }
                }
                .overlay {
                    if self.参加完了バナーを表示 {
                        Label("アクティビティに参加しました", systemImage: "checkmark")
                            .font(.headline)
                            .padding(12)
                            .border(.primary)
                            .background(.background)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation(.default.speed(0.33)) {
                                        self.参加完了バナーを表示 = false
                                    }
                                }
                            }
                    }
                }
        }
    }
}

struct SharePlayインジケーター: View {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject private var groupStateObserver = GroupStateObserver()
    private var SharePlay中: Bool {
        [.waiting, .joined].contains(モデル.グループセッション?.state)
    }
    private var 参加人数: String { モデル.参加人数?.description ?? "0" }
    var body: some View {
        if self.groupStateObserver.isEligibleForGroupSession {
            Button {
                モデル.表示中のシート = .SharePlayガイド
            } label: {
                Group {
                    if self.SharePlay中 {
                        Label("現在、\(self.参加人数)人でSharePlay中", systemImage: "shareplay")
                            .animation(.default, value: self.参加人数)
                    } else {
                        Label("現在、SharePlayしていません", systemImage: "shareplay.slash")
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.1)
            }
            .accessibilityLabel("SharePlayメニュー")
            .modifier(Self.ボタンスタイル())
            .buttonBorderShape(.capsule)
            .padding(.top, 固定値.SharePlayインジケーター上部パディング)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .foregroundStyle(self.SharePlay中 ? .primary : .secondary)
        }
    }
    private struct ボタンスタイル: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        func body(content: Content) -> some View {
            if モデル.グループセッション != nil {
                content
                    .buttonStyle(.automatic)
                    .font(.subheadline.weight(.light))
            } else {
                content
                    .buttonStyle(.bordered)
                    .font(.caption.weight(.light))
            }
        }
    }
}

struct SharePlayガイド: View {
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
            Section { SharePlay紹介リンク() }
        }
        .animation(.default, value: self.SharePlay中)
        .navigationTitle("共有将棋盤")
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
            Text("友達が既に「共有将棋盤」アクティビティを起動している場合は、システム側のUIを操作してアクティビティに参加しましょう。")
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
                Label("アクティビティ「共有将棋盤」を起動する", systemImage: "power")
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
                        フィードバック.警告()
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
                        フィードバック.軽め()
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
                        フィードバック.エラー()
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

struct SharePlay紹介リンク: View {
    var body: some View {
        NavigationLink {
            List {
                self.概要セクション()
                self.招待ボタン()
                Section {
                    Text("FaceTime中にこのアプリを立ち上げると、アクティビティを起動することが出来ます。アクティビティを起動すると、通話相手のデバイスではSharePlay参加を促す通知が表示されます。")
                        .padding(8)
                    Image("joinFromBanner")
                        .resizable()
                        .scaledToFit()
                        .border(.black)
                        .frame(maxWidth: .infinity, maxHeight: 180)
                } header: {
                    Text("はじめ方")
                }
                if #available(iOS 16, *) { self.メッセージアプリ説明セクション() }
                self.注意事項セクション()
                self.データ管理説明セクション()
            }
            .navigationTitle("SharePlayについて")
        } label: {
            Label("SharePlayについて", systemImage: "shareplay")
        }
    }
    private func 概要セクション() -> some View {
        Section {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 1)
                    .foregroundStyle(.quaternary)
                    .frame(width: 4)
                VStack(alignment: .leading, spacing: 8) {
                    Text("\"FaceTime App でSharePlayを使用すると、友達や家族とのFaceTime通話中にテレビ番組、映画、ミュージックを同期した状態でストリーム再生することができます。通話に参加しているほかの人とリアルタイムにつながって楽しみましょう。再生が同期され、コントロールが共有されるため、同時に同じ瞬間を見たり聞いたりできます。\"")
                    Text("\"SharePlayは、FaceTime通話中にほかのAppでも使用できます。\"")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(6)
            Link(destination: URL(string: "https://support.apple.com/guide/iphone/shareplay-watch-listen-play-iphb657eb791/ios")!) {
                Label("引用: Apple サポートサイト", systemImage: "link")
                    .font(.subheadline)
            }
            .accessibilityLabel("Appleサポートサイトを開く")
        } header: {
            Text("概要")
                .textCase(.none)
        } footer: {
            Text("https://support.apple.com/guide/iphone/shareplay-watch-listen-play-iphb657eb791/ios")
        }
    }
    private func 招待ボタン() -> some View {
#if !targetEnvironment(macCatalyst)
        SharingControllerボタン()
#else
        EmptyView()
#endif
    }
    private func メッセージアプリ説明セクション() -> some View {
        Section {
            Text("iOS 16 以降のデバイスでは、「メッセージ」アプリでもSharePlayを利用できます。「メッセージ」アプリで「共有将棋盤」アクティビティに招待された場合は、「メッセージ」アプリ上から参加してください。")
                .padding(8)
            Image("joinFromMessage")
                .resizable()
                .scaledToFit()
                .border(.black)
                .frame(maxWidth: .infinity, maxHeight: 120)
        }
    }
    private func 注意事項セクション() -> some View {
        Section {
            Text("""
                **以下の項目はユーザー間で同期されません**
                ・各種オプション(上下反転/セリフ体/太字/駒のサイズ/English表記/強調表示常時オフ)
                ・駒増減モードに移行しているかどうか
                ・選択中の駒の様子(駒の移動等を完了させたタイミングで操作結果が同期されます)
                ・ドラッグしている最中の駒の様子(ドラッグを完了させたタイミングで操作結果が同期されます)
                """)
            .lineSpacing(6)
            .font(.subheadline)
            .padding(8)
        } header: {
            Label("注意事項", systemImage: "exclamationmark.triangle")
        }
    }
    private func データ管理説明セクション() -> some View {
        Section {
            Text("SharePlayではユーザーのデバイス間で同期するすべてのセッションデータに対してエンドツーエンド暗号化が用いられます。アプリ開発者やAppleは、このデータの復号鍵を保持していません。つまり、SharePlay中に通信されるデータを第三者が確認する事はありません。")
                .font(.subheadline)
                .padding(8)
        } header: {
            Text("データ管理")
        }
    }
}

#if !targetEnvironment(macCatalyst)
private struct SharingControllerボタン: View {
    @State private var sharingControllerを表示: Bool = false
    @State private var groupActivity準備完了: Bool = false
    @StateObject private var groupStateObserver = GroupStateObserver()
    var body: some View {
        Section {
            Button {
                self.sharingControllerを表示 = true
            } label: {
                if #available(iOS 16, *) {
                    Label("友達に「FaceTime」で通話をかけるか、もしくは「メッセージ」で連絡する", systemImage: "person.badge.plus")
                } else {
                    Label("友達に「FaceTime」通話をかける", systemImage: "person.badge.plus")
                }
            }
            .disabled(self.groupStateObserver.isEligibleForGroupSession)
        } header: {
            Text("SharePlayの準備をする")
                .textCase(.none)
        }
        .sheet(isPresented: self.$sharingControllerを表示) {
            Self.🅂haringControllerView(self.$groupActivity準備完了)
        }
        .onChange(of: groupStateObserver.isEligibleForGroupSession) { newValue in
            if newValue {
                if self.groupActivity準備完了 {
                    🄶roupActivity.アクティビティを起動する()
                    self.groupActivity準備完了 = false
                }
            }
        }
    }
    private struct 🅂haringControllerView: UIViewControllerRepresentable {
        private let groupActivitySharingController: GroupActivitySharingController
        @Binding var groupActivity準備完了: Bool
        func makeUIViewController(context: Context) -> GroupActivitySharingController {
            Task {
                switch await self.groupActivitySharingController.result {
                    case .success:
                        print("🖨️ groupActivitySharingController.result: success")
                        self.groupActivity準備完了 = true
                    case .cancelled:
                        print("🖨️ groupActivitySharingController.result: cancelled")
                    @unknown default:
                        assertionFailure()
                }
            }
            return self.groupActivitySharingController
        }
        func updateUIViewController(_ controller: GroupActivitySharingController, context: Context) {
            print("🖨️ updateUIViewController/context", context)
        }
        init?(_ groupActivity準備完了: Binding<Bool>) {
            do {
                self.groupActivitySharingController = try GroupActivitySharingController(🄶roupActivity())
            } catch {
                print("🚨", #line, error.localizedDescription)
                return nil
            }
            self._groupActivity準備完了 = groupActivity準備完了
        }
    }
}
#endif
