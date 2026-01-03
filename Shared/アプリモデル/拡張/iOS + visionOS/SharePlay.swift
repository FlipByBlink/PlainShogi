#if os(iOS) || os(visionOS)
import SwiftUI
import GroupActivities

extension アプリモデル {
    func 新規GroupSessionを受信したら設定する() async {
        for await 新規セッション in 🄶roupActivity.sessions() {
            self.駒の選択を解除する()
            self.局面.何も無い状態に変更する()
            self.グループセッション = 新規セッション
            let 新規メッセンジャー = GroupSessionMessenger(session: 新規セッション)
            self.セッションメッセンジャー = 新規メッセンジャー
            新規セッション.$state
                .sink {
                    if case .invalidated = $0 {
                        self.グループセッション = nil
                        self.アクティビティをリセットする()
                    }
                }
                .store(in: &self.サブスクリプションズ)
            新規セッション.$activeParticipants
                .sink { activeParticipants in
                    self.参加人数 = activeParticipants.count
                    if activeParticipants.count == 1, self.局面.駒が1つも無い {
                        self.局面.現在の局面として適用する(.初期セット)
                    }
                    guard self.局面.SharePlay共有可能 else { return }
                    let 新規参加者達 = activeParticipants.subtracting(新規セッション.activeParticipants)
                    Task {
                        try? await 新規メッセンジャー.send(self.局面, to: .only(新規参加者達))
                    }
                }
                .store(in: &self.サブスクリプションズ)
            self.タスクス.insert(
                Task {
                    for await (受け取った局面, _) in 新規メッセンジャー.messages(of: 局面モデル.self) {
                        guard self.局面 != 受け取った局面 else { continue }
                        self.SharePlay中に共有相手から送信されたモデルを適用する(受け取った局面)
                    }
                }
            )
            self.タスクス.insert(
                Task {
                    for await (メッセージ, _) in 新規メッセンジャー.messages(of: SharePlay用選択中の駒モデル.self) {
                        self.選択中の駒 = メッセージ.値
                        self.visionOSでの駒持ち上げ状態をリセット()
                    }
                }
            )
            await self.visionOSでの立ち位置を設定(新規セッション)
            新規セッション.join()
        }
    }
    private func SharePlay中に共有相手から送信されたモデルを適用する(_ 新規局面: 局面モデル) {
        withAnimation(.default.speed(2.5)) {
            self.局面.更新日時を変更せずにモデルを適用する(新規局面)
        }
        self.駒の選択を解除する()
        self.フィードバック.強め()
    }
    private func アクティビティをリセットする() {
        self.セッションメッセンジャー = nil
        self.タスクス.forEach { $0.cancel() }
        self.タスクス = []
        self.サブスクリプションズ = []
        self.参加人数 = nil
        if self.グループセッション != nil {
            self.グループセッション?.leave()
            self.グループセッション = nil
            🄶roupActivity.アクティビティを起動する()
        }
    }
    func SharePlay中なら現在の局面を参加者に送信する() {
        if let セッションメッセンジャー {
            guard self.局面.SharePlay共有可能 else { assertionFailure(); return }
            Task {
                do {
                    try await セッションメッセンジャー.send(self.局面)
                } catch {
                    print("🚨", #function, #line, error.localizedDescription)
                }
            }
        }
    }
    func SharePlay中なら現在の選択中の駒を参加者に送信する() {
        if let セッションメッセンジャー {
            guard self.局面.SharePlay共有可能 else { assertionFailure(); return }
            Task {
                do {
                    try await セッションメッセンジャー.send(SharePlay用選択中の駒モデル(値: self.選択中の駒))
                } catch {
                    print("🚨", #function, #line, error.localizedDescription)
                }
            }
        }
    }
    var セッションステート表記: LocalizedStringKey {
        switch self.グループセッション?.state {
            case .waiting: "待機中"
            case .joined: "参加中"
            case .invalidated(_): "無効"
            case .none: "なし"
            @unknown default: "!想定外!"
        }
    }
    private func visionOSでの立ち位置を設定(_ セッション: GroupSession<🄶roupActivity>) async {
#if os(visionOS)
        await
        セッション
            .systemCoordinator?
            .configuration
            .spatialTemplatePreference = .conversational
#endif
    }
    private func visionOSでの駒持ち上げ状態をリセット() {
#if os(visionOS)
        self.駒を持ち上げたのは自分 = false
#endif
    }
}
/*
==== Sample code ====
https://developer.apple.com/documentation/groupactivities/drawing_content_in_a_group_session
*/
#endif




#if os(watchOS) || os(tvOS)
extension アプリモデル {
    func SharePlay中なら現在の選択中の駒を参加者に送信する() {
        //Unsupport on watchOS, tvOS
    }
    func SharePlay中なら現在の局面を参加者に送信する() {
        //Unsupport on watchOS, tvOS
    }
}
#endif
