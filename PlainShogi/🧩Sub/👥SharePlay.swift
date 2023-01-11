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

struct 🅂haringControllerボタン: View {
    @State private var 🚩SharingControllerを表示: Bool = false
    @State private var 🚩GroupActivity準備完了: Bool = false
    @StateObject private var ⓖroupStateObserver = GroupStateObserver()
    var body: some View {
        Section {
            Button {
                🚩SharingControllerを表示 = true
            } label: {
                Label("友達に「FaceTime」で通話をかけるか、もしくは「メッセージ」で連絡する", systemImage: "person.badge.plus")
            }
            .disabled(self.ⓖroupStateObserver.isEligibleForGroupSession)
        } header: {
            Text("SharePlayの準備をする")
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

struct SharePlayインジケーター: View { //TODO: WIP
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
                    Section {
                        Text("現在、友達と繋がっているようです。友達が立ち上げたアクティビティに参加するか、もしくは自分でアクティビティを起動しましょう。")
                            .padding(.vertical, 12)
                    } header: {
                        Text("事前準備完了")
                    }
                    self.アクティビティ参加誘導セクション()
                    self.アクティビティ起動誘導セクション()
                }
                self.ステータスセクション()
                Section { SharePlay紹介リンク() }
            }
            .navigationTitle("共有将棋盤")
            .toolbar { self.閉じるボタン() }
        }
    }
    private func アクティビティ参加誘導セクション() -> some View {
        Section {
            Text("友達が既に「共有将棋盤」アクティビティを起動している場合は、システム側のUIを操作してアクティビティに参加しましょう。")
            if #available(iOS 16, *) {
                Text("「メッセージ」アプリで「共有将棋盤」アクティビティに招待された場合は、「メッセージ」アプリ上から参加してください。")
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
                    .font(.body.weight(.medium))
                    .padding(.vertical, 6)
            }
            .disabled(📱.ⓖroupSession != nil)
        } header: {
            Text("自分からSharePlayを開始する")
                .textCase(.none)
        }
        .font(.subheadline)
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
                Section {
                    Text("SharePlayとは、、、")
                } header: {
                    Text("SharePlayとは")
                        .textCase(.none)
                }
                🅂haringControllerボタン()
                Section {
                    Text("placeholder")
                } header: {
                    Text("注意事項")
                }
                self.データ管理説明セクション()
            }
            .navigationTitle("SharePlayについて")
        } label: {
            Label("SharePlayについて", systemImage: "shareplay")
        }
    }
    private func データ管理説明セクション() -> some View {
        Section {
            Text("SharePlayではユーザーのデバイス間で同期するすべてのセッションデータに対してエンドツーエンド暗号化が用いられます。アプリ開発者やAppleは、このデータの復号鍵を保持していません。つまり、SharePlay中に通信されるデータを第三者が確認する事はありません。")
        } header: {
            Text("データ管理")
        }
    }
}
