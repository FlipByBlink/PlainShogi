import Foundation
import GroupActivities
import UIKit
import SwiftUI

struct 🄶roupActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var ⓜetadata = GroupActivityMetadata()
        ⓜetadata.title = NSLocalizedString("共有将棋盤", comment: "アクティビティタイトル")
        ⓜetadata.type = .generic
        ⓜetadata.previewImage = UIImage(named: "previewImage")!.cgImage
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

struct 👥SharePlay環境構築: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    func body(content: Content) -> some View {
        content
            .animation(.default, value: self.ⓖroupStateObserver.isEligibleForGroupSession)
            .animation(.default, value: 📱.ⓖroupSession?.state)
            .task { await 📱.新規GroupSessionを受信したら設定する() }
            .modifier(参加完了通知バナー())
    }
}

private struct 参加完了通知バナー: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @State private var 🚩SharePlay参加完了バナーを表示: Bool = false
    func body(content: Content) -> some View {
        content
            .onChange(of: 📱.ⓖroupSession != nil) {
                if $0 {
                    withAnimation(.default.speed(2)) {
                        self.🚩SharePlay参加完了バナーを表示 = true
                    }
                }
            }
            .overlay {
                if self.🚩SharePlay参加完了バナーを表示 {
                    Label("アクティビティに参加しました", systemImage: "checkmark")
                        .font(.headline)
                        .padding(12)
                        .border(.primary)
                        .background(.background)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.default.speed(0.33)) {
                                    self.🚩SharePlay参加完了バナーを表示 = false
                                }
                            }
                        }
                }
            }
    }
}

struct 👥SharePlayインジケーター: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    private var 🚩SharePlay中: Bool {
        📱.ⓖroupSession?.state == .waiting ||
        📱.ⓖroupSession?.state == .joined
    }
    @State private var 🚩ガイドを表示: Bool = false
    private var 参加人数: String { 📱.参加人数?.description ?? "0" }
    var body: some View {
        if self.ⓖroupStateObserver.isEligibleForGroupSession {
            Button {
                self.🚩ガイドを表示 = true
                💥フィードバック.軽め()
            } label: {
                Group {
                    if self.🚩SharePlay中 {
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
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .foregroundStyle(self.🚩SharePlay中 ? .primary : .secondary)
            .sheet(isPresented: self.$🚩ガイドを表示) {
                NavigationView {
                    👥SharePlayガイド(self.$🚩ガイドを表示)
                        .toolbar { self.閉じるボタン() }
                }
                .navigationViewStyle(.stack)
            }
        }
    }
    private struct ボタンスタイル: ViewModifier {
        @EnvironmentObject var 📱: 📱アプリモデル
        func body(content: Content) -> some View {
            if 📱.ⓖroupSession != nil {
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
    private func 閉じるボタン() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                self.🚩ガイドを表示 = false
                💥フィードバック.軽め()
            } label: {
                Image(systemName: "chevron.down")
                    .grayscale(1.0)
            }
            .accessibilityLabel("Dismiss")
        }
    }
}

struct 👥SharePlayガイド: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Binding private var 🚩シートを表示: Bool
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    private var 🚩SharePlay中: Bool {
        📱.ⓖroupSession?.state == .waiting ||
        📱.ⓖroupSession?.state == .joined
    }
    var body: some View {
        List {
            if !self.🚩SharePlay中 {
                self.事前準備完セクション()
                self.アクティビティ参加誘導セクション()
                self.アクティビティ起動誘導セクション()
            }
            self.ステータスセクション()
            self.離脱ボタンや終了ボタン()
            Section { 👥SharePlay紹介リンク() }
        }
        .animation(.default, value: self.🚩SharePlay中)
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
                self.🚩シートを表示 = false
            } label: {
                Label("アクティビティ「共有将棋盤」を起動する", systemImage: "power")
                    .font(.body.weight(.medium))
                    .padding(.vertical, 4)
            }
            .disabled(📱.ⓖroupSession != nil)
        } header: {
            Text("自分からSharePlayを開始する")
                .textCase(.none)
        }
    }
    @State private var 🚩終了確認ダイアログ表示: Bool = false
    private func 離脱ボタンや終了ボタン() -> some View {
        Group {
            if self.🚩SharePlay中 {
                Section {
                    Button {
                        📱.ⓖroupSession?.leave()
                        💥フィードバック.警告()
                        self.🚩シートを表示 = false
                    } label: {
                        Label("アクティビティから離脱する", systemImage: "escape")
                    }
                } footer: {
                    Text("アクティビティから離脱しても、自分以外はアクティビティに参加したままです。")
                }
                Section {
                    Button {
                        self.🚩終了確認ダイアログ表示 = true
                        💥フィードバック.軽め()
                    } label: {
                        Label("アクティビティを終了する", systemImage: "power.dotted")
                    }
                } footer: {
                    Text("アクティビティを終了すると、全員がアクティビティから離脱します。")
                }
                .confirmationDialog("アクティビティを終了しますか？",
                                    isPresented: self.$🚩終了確認ダイアログ表示,
                                    titleVisibility: .visible) {
                    Button(role: .destructive) {
                        📱.ⓖroupSession?.end()
                        💥フィードバック.エラー()
                        self.🚩シートを表示 = false
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
            if 📱.ⓖroupSession != nil {
                Section {
                    Label("アクティビティ", systemImage: "power")
                        .badge(📱.セッションステート表記)
                    if let アクティブ参加者数 = 📱.ⓖroupSession?.activeParticipants.count {
                        Label("現在の参加者数", systemImage: "person.3")
                            .badge(アクティブ参加者数)
                    }
                } header: {
                    Text("状況")
                }
            }
        }
    }
    init(_ シートを表示: Binding<Bool>) {
        self._🚩シートを表示 = シートを表示
    }
}

struct 👥SharePlay紹介リンク: View {
    var body: some View {
        NavigationLink {
            List {
                self.概要セクション()
                SharingControllerボタン()
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
                ・「上下反転」オプション
                ・「English表記」オプション
                ・「強調表示を常時オフ」オプション
                ・編集モードに移行しているかどうか
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

private struct SharingControllerボタン: View {
    @State private var 🚩SharingControllerを表示: Bool = false
    @State private var 🚩GroupActivity準備完了: Bool = false
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        Section {
            Button {
                self.🚩SharingControllerを表示 = true
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
        .sheet(isPresented: self.$🚩SharingControllerを表示) {
            Self.🅂haringControllerView(self.$🚩GroupActivity準備完了)
        }
        .onChange(of: ⓖroupStateObserver.isEligibleForGroupSession) { ⓝewValue in
            if ⓝewValue {
                if self.🚩GroupActivity準備完了 {
                    🄶roupActivity.アクティビティを起動する()
                    self.🚩GroupActivity準備完了 = false
                }
            }
        }
    }
    private struct 🅂haringControllerView: UIViewControllerRepresentable {
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
            return self.ⓖroupActivitySharingController
        }
        func updateUIViewController(_ ⓒontroller: GroupActivitySharingController, context: Context) {
            print("🖨️ updateUIViewController/context", context)
        }
        init?(_ GroupActivity準備完了: Binding<Bool>) {
            do {
                self.ⓖroupActivitySharingController = try GroupActivitySharingController(🄶roupActivity())
            } catch {
                print("🚨", #line, error.localizedDescription)
                return nil
            }
            self._🚩GroupActivity準備完了 = GroupActivity準備完了
        }
    }
}
