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
