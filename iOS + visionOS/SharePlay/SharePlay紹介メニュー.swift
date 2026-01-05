import SwiftUI
import GroupActivities
import UIKit

struct SharePlay紹介メニューリンク: View {
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
                self.メッセージアプリ説明セクション()
                self.NameDropスタイル説明セクション()
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
            Text(verbatim: "https://support.apple.com/guide/iphone/shareplay-watch-listen-play-iphb657eb791/ios")
        }
    }
    private func 招待ボタン() -> some View {
#if !targetEnvironment(macCatalyst) && os(iOS)
        SharingControllerボタン()
#else
        EmptyView()
#endif
    }
    private func メッセージアプリ説明セクション() -> some View {
#if os(iOS)
        Section {
            Text("iOS 16 以降のデバイスでは、「メッセージ」アプリでもSharePlayを利用できます。「メッセージ」アプリで「将棋盤」アクティビティに招待された場合は、「メッセージ」アプリ上から参加してください。")
                .padding(8)
            Image("joinFromMessage")
                .resizable()
                .scaledToFit()
                .border(.black)
                .frame(maxWidth: .infinity, maxHeight: 120)
        }
#elseif os(visionOS)
        EmptyView()
#endif
    }
    private func NameDropスタイル説明セクション() -> some View {
#if os(iOS)
        Section {
            VStack {
                Image(.nameDropBump)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 140)
                Text("iOS 17 以降の2台のiPhoneの上部を近付けるだけでSharePlayを開始できます。")
            }
            .padding(.vertical)
            HStack {
                Image(.bumpSharePlayButton)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                    .padding(8)
                Text("2台のiPhoneの上部を近付けると「SharePlay」と書かれたボタンが表示されます。そのボタンを押すと「将棋盤」アクティビティを起動され、相手にアクティビティの招待を送ります。")
            }
            /* iOS 17.1 で挙動が不正確になったため一旦コメントアウト
             HStack {
             Image(.openSharePlayButton)
             .resizable()
             .scaledToFit()
             .frame(width: 120)
             .padding(8)
             Text("招待された側は、上部のメニューの「開く」ボタンを押してください。本アプリが起動され、アクティビティに自動的に参加します。")
             }
             */
        } footer: {
            Text("Apple IDに紐付いた連絡先を知らない場合は、同じジェスチャーをした際にNameDrop(連絡先を交換するための機能)が起動します。")
        }
#elseif os(visionOS)
        EmptyView()
#endif
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
                Label {
#if os(iOS)
                    Text("友達に「FaceTime」で通話をかけるか、もしくは「メッセージ」で連絡する")
#elseif os(visionOS)
                    Text("友達に声を掛ける")
#endif
                } icon: {
                    Image(systemName: "person.badge.plus")
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
        .onChange(of: groupStateObserver.isEligibleForGroupSession) {
            if $1 {
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
