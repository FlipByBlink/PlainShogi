import Foundation
import GroupActivities
import UIKit
import SwiftUI

struct 🄶roupActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var ⓜetadata = GroupActivityMetadata()
        ⓜetadata.title = NSLocalizedString("共有将棋盤", comment: "アクティビティタイトル")
        ⓜetadata.type = .generic
        ⓜetadata.previewImage = UIImage(systemName: "questionmark.square.dashed")!.cgImage
        return ⓜetadata
    }
    static func アクティビティを起動する() {
        Task {
            do {
                let ⓐctivity = Self()
                switch await ⓐctivity.prepareForActivation() {
                    case .activationPreferred:
                        print("ⓐctivity.prepareForActivation: activationPreferred")
                        let 結果 = try await ⓐctivity.activate()
                        if !結果 {
                            throw 🚨エラー.activation失敗
                        }
                    case .activationDisabled:
                        print("ⓐctivity.prepareForActivation: activationDisabled")
                    case .cancelled:
                        print("ⓐctivity.prepareForActivation: cancelled")
                    @unknown default:
                        throw 🚨エラー.unknown
                }
            } catch {
                print("🚨 activation 失敗: \(error)")
                assertionFailure()
            }
            enum 🚨エラー: Error {
                case activation失敗, unknown
            }
        }
    }
}

struct SharePlay環境構築: ViewModifier {
    @EnvironmentObject var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    func body(content: Content) -> some View {
        content
            .animation(.default, value: self.ⓖroupStateObserver.isEligibleForGroupSession)
            .animation(.default, value: 📱.ⓖroupSession?.state)
            .task { await 📱.新規GroupSessionを受信したら設定する() }
    }
}

struct SharePlayインジケーター: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    private var 🚩SharePlay中: Bool {
        📱.ⓖroupSession?.state == .waiting
        ||
        📱.ⓖroupSession?.state == .joined
    }
    @State private var 🚩メニューを表示: Bool = false
    var body: some View {
        if self.ⓖroupStateObserver.isEligibleForGroupSession {
            Button {
                self.🚩メニューを表示 = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Group {
                    if self.🚩SharePlay中 {
                        Label("現在、SharePlay中", systemImage: "shareplay")
                    } else {
                        Label("現在、SharePlayしていません", systemImage: "shareplay.slash")
                    }
                }
                .font(.caption.weight(.light))
                .foregroundColor(self.🚩SharePlay中 ? .primary : .secondary)
            }
            .sheet(isPresented: self.$🚩メニューを表示) { self.メニュー() }
            .minimumScaleFactor(0.1)
            .padding(.bottom, 8)
            .frame(maxHeight: 36)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
    private func メニュー() -> some View {
        NavigationView {
            List {
                if !self.🚩SharePlay中 {
                    self.事前準備完セクション()
                    self.アクティビティ参加誘導セクション()
                    self.アクティビティ起動誘導セクション()
                }
                self.ステータスセクション()
                self.離脱ボタンや終了ボタン()
                Section { SharePlay紹介リンク() }
            }
            .navigationTitle("共有将棋盤")
            .toolbar { self.閉じるボタン() }
        }
    }
    private func 事前準備完セクション() -> some View {
        Section {
            Text("現在、友達と繋がっているようです。友達が立ち上げたアクティビティに参加するか、もしくは自分でアクティビティを起動しましょう。")
                .padding(.vertical, 12)
        } header: {
            Text("事前準備完了")
        }
    }
    private func アクティビティ参加誘導セクション() -> some View {
        Section {
            VStack {
                Text("友達が既に「共有将棋盤」アクティビティを起動している場合は、システム側のUIを操作してアクティビティに参加しましょう。")
                プレースホルダーView()
            }
            if #available(iOS 16, *) {
                VStack {
                    Text("iOS 16 以降のデバイスでは、「メッセージ」アプリでもSharePlayを利用できます。「メッセージ」アプリで「共有将棋盤」アクティビティに招待された場合は、「メッセージ」アプリ上から参加してください。")
                    プレースホルダーView()
                }
            }
        } header: {
            Text("SharePlayに参加する")
                .textCase(.none)
        }
        .font(.subheadline)
    }
    private func アクティビティ起動誘導セクション() -> some View {
        Section {
            Text("自分からSharePlayを開始する事もできます。アクティビティを起動したら友達にSharePlay参加を促しましょう。")
            Button {
                🄶roupActivity.アクティビティを起動する()
                self.🚩メニューを表示 = false
            } label: {
                Label("「共有将棋盤」アクティビティを起動する", systemImage: "power")
                    .padding(.vertical, 6)
            }
            .disabled(📱.ⓖroupSession != nil)
        } header: {
            Text("自分からSharePlayを開始する")
                .textCase(.none)
        }
        .font(.subheadline)
    }
    private func 離脱ボタンや終了ボタン() -> some View {
        Group {
            if self.🚩SharePlay中 {
                Section {
                    Button {
                        📱.ⓖroupSession?.leave()
                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    } label: {
                        Label("アクティビティから離脱する", systemImage: "escape")
                    }
                } footer: {
                    Text("アクティビティから離脱しても、自分以外はアクティビティに参加したままです。")
                }
                Section {
                    Menu {
                        Button(role: .destructive) {
                            📱.ⓖroupSession?.end()
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        } label: {
                            Label("はい、アクティビティを終了します", systemImage: "power.dotted")
                        }
                    } label: {
                        Label("アクティビティを終了する", systemImage: "power.dotted")
                    }
                } footer: {
                    Text("アクティビティを終了すると、全員がアクティビティから離脱します。")
                }
            }
        }
    }
    private func ステータスセクション() -> some View {
        Group {
            if 📱.ⓖroupSession != nil {
                Section {
                    Label("セッション", systemImage: "power")
                        .badge(📱.セッション状態表記)
                    if let アクティブ参加者数 = 📱.ⓖroupSession?.activeParticipants.count {
                        Label("アクティブ参加者数", systemImage: "person.3")
                            .badge(アクティブ参加者数)
                    }
                } header: {
                    Text("状況")
                }
            }
        }
    }
    private func 閉じるボタン() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                self.🚩メニューを表示 = false
                振動フィードバック()
            } label: {
                Image(systemName: "chevron.down")
                    .foregroundStyle(.secondary)
                    .grayscale(1.0)
                    .padding(8)
            }
            .accessibilityLabel("Dismiss")
        }
    }
}

struct SharePlay紹介リンク: View {
    @EnvironmentObject var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        NavigationLink {
            List {
                self.概要セクション()
                🅂haringControllerボタン()
                Section {
                    VStack {
                        Text("FaceTime中にこのアプリを立ち上げると、アクティビティを起動するためのボタンが出現します。このボタンを押すとSharePlayが開始され、通話相手のデバイスではSharePlay参加を促す通知が表示されます。")
                        プレースホルダーView()
                    }
                } header: {
                    Text("はじめ方")
                }
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
                VStack(spacing: 10) {
                    Text(#""FaceTime App でSharePlayを使用すると、友達や家族とのFaceTime通話中にテレビ番組、映画、ミュージックを同期した状態でストリーム再生することができます。通話に参加しているほかの人とリアルタイムにつながって楽しみましょう。再生が同期され、コントロールが共有されるため、同時に同じ瞬間を見たり聞いたりできます。""#)
                    Text(#""SharePlayは、FaceTime通話中にほかのAppでも使用できます。""#)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(6)
            Link(destination: URL(string: "https://support.apple.com/guide/iphone/shareplay-watch-listen-play-iphb657eb791/ios")!) {
                Label("引用: Apple サポートサイト", systemImage: "link")
                    .font(.subheadline)
            }
        } header: {
            Text("概要")
                .textCase(.none)
        } footer: {
            Text("https://support.apple.com/guide/iphone/shareplay-watch-listen-play-iphb657eb791/ios")
        }
    }
    private func 注意事項セクション() -> some View {
        Section {
            Text("""
                以下の項目はユーザー間で同期されません
                ・「上下反転」オプション
                ・「English表記」オプション
                ・「常時強調表示オフ」オプション
                ・ドラッグしている最中の駒の様子(ドラッグを完了させたタイミングで操作結果が同期されます)
                ・編集モードに移行しているかどうか
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

struct 🅂haringControllerボタン: View {
    @State private var 🚩SharingControllerを表示: Bool = false
    @State private var 🚩GroupActivity準備完了: Bool = false
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        Section {
            Button {
                🚩SharingControllerを表示 = true
            } label: {
                if #available(iOS 16, *) {
                    Label("友達に「FaceTime」で通話をかけるか、もしくは「メッセージ」で連絡する", systemImage: "person.badge.plus")
                } else {
                    Label("友達に「FaceTime」通話をかける", systemImage: "person.badge.plus")
                }
            }
            .disabled(self.ⓖroupStateObserver.isEligibleForGroupSession)
        } header: {
            Text("SharePlayの準備をする")
                .textCase(.none)
        }
        .sheet(isPresented: $🚩SharingControllerを表示) {
            🅂haringControllerView($🚩GroupActivity準備完了)
        }
        .onChange(of: ⓖroupStateObserver.isEligibleForGroupSession) { ⓝewValue in
            if ⓝewValue {
                if 🚩GroupActivity準備完了 {
                    🄶roupActivity.アクティビティを起動する()
                    🚩GroupActivity準備完了 = false
                }
            }
        }
    }
    struct 🅂haringControllerView: UIViewControllerRepresentable {
        private let ⓖroupActivitySharingController: GroupActivitySharingController
        @Binding var 🚩GroupActivity準備完了: Bool
        func makeUIViewController(context: Context) -> GroupActivitySharingController {
            Task {
                switch await self.ⓖroupActivitySharingController.result {
                    case .success:
                        print("🖨️ groupActivitySharingController.result: success")
                        self.🚩GroupActivity準備完了 = true
                    case .cancelled:
                        print("🖨️ groupActivitySharingController.result: cancelled")
                    @unknown default:
                        assertionFailure()
                }
            }
            return ⓖroupActivitySharingController
        }
        func updateUIViewController(_ ⓒontroller: GroupActivitySharingController, context: Context) {
            print("🖨️ updateUIViewController/context", context)
        }
        init?(_ 🚩GroupActivity準備完了: Binding<Bool>) {
            do {
                self.ⓖroupActivitySharingController = try GroupActivitySharingController(🄶roupActivity())
            } catch {
                print("🚨", #line, error.localizedDescription)
                return nil
            }
            self._🚩GroupActivity準備完了 = 🚩GroupActivity準備完了
        }
    }
}
