import Combine
import SwiftUI
import UniformTypeIdentifiers
#if os(iOS) || os(visionOS)
import GroupActivities
#endif

@MainActor
class アプリモデル: スーパークラス, ObservableObject {
    @Published private(set) var 局面: 局面モデル = .前回の局面 ?? .初期セット
    
    @AppStorage("English表記") var english表記: Bool = false
    @AppStorage("直近操作強調表示機能オフ") var 直近操作強調表示機能オフ: Bool = false
    @AppStorage("上下反転") var 上下反転: Bool = false
    @AppStorage("セリフ体") var セリフ体: Bool = false
    @AppStorage("太字") var 太字: Bool = false
    @AppStorage("サイズ") var サイズ: 字体.サイズ = .標準
    
    @Published var 表示中のシート: シートカテゴリ? = nil
    @Published var 成駒確認アラートを表示: Bool = false
    @Published private(set) var 増減モード中: Bool = false
    @Published private(set) var 選択中の駒: 駒の場所 = .なし
    
    private var フィードバック: フィードバックモデル = .init()
    
    override init() {
        super.init()
        ICloudデータ.addObserver(self, #selector(self.iCloudによる外部からの履歴変更を適用する(_:)))
        ICloudデータ.synchronize()
    }
    
#if os(iOS) || os(visionOS)
    // ↓ ドラッグ&ドロップ関連
    @Published private(set) var ドラッグ中の駒: ドラッグ対象 = .無し
    // ↓ SharePlay関連
    private var サブスクリプションズ = Set<AnyCancellable>()
    private var タスクス = Set<Task<Void, Never>>()
    @Published private(set) var グループセッション: GroupSession<🄶roupActivity>?
    private var セッションメッセンジャー: GroupSessionMessenger?
    @Published private(set) var 参加人数: Int?
#endif
    
#if os(visionOS)
    @AppStorage("暗転モード") var 暗転モード: Bool = false
    @Published private(set) var 駒を持ち上げたのは自分: Bool = false
#endif
}

//MARK: - ==== 局面関連 ====
extension アプリモデル {
    func この駒の表記(_ 場所: 駒の場所) -> String? {
        self.局面.この駒の表記(場所, self.english表記)
    }
    func 手駒増減メニューの駒の表記(_ 職名: 駒の種類, _ 陣営: 王側か玉側か) -> String {
        self.english表記 ? 職名.english生駒表記 : 職名.生駒表記(陣営)
    }
    func この駒のプレビュー表記(_ 場所: 駒の場所) -> String? {
        self.局面.この駒の職名表記(場所, self.english表記)
    }
    func この駒は操作直後なので強調表示(_ 場所: 駒の場所) -> Bool {
        (self.局面.直近の操作 == 場所) && !self.直近操作強調表示機能オフ
    }
    func この駒にはアンダーラインが必要(_ 場所: 駒の場所) -> Bool {
        self.局面.この駒にはアンダーラインが必要(場所, self.english表記)
    }
    func この駒は下向き(_ 場所: 駒の場所) -> Bool {
        (self.局面.この駒の陣営(場所) == .玉側) != self.上下反転
    }
    func こちら側のボタンは下向き(_ 陣営: 王側か玉側か) -> Bool {
        (陣営 == .玉側) != self.上下反転
    }
    func こちら側の陣営(_ 立場: 手前か対面か) -> 王側か玉側か {
        switch (立場, self.上下反転) {
            case (.手前, false): .王側
            case (.対面, false): .玉側
            case (.手前, true): .玉側
            case (.対面, true): .王側
        }
    }
    var 何も強調表示されていない: Bool {
        self.局面.直近の操作 == .なし && self.選択中の駒 == .なし
    }
    var 強調表示常時オフかつ駒が選択されていない: Bool {
        self.直近操作強調表示機能オフ && (self.選択中の駒 == .なし)
    }
    func 強調表示をクリア() {
        withAnimation {
            self.局面.直近操作情報を消す()
            self.選択中の駒の値を変更する(.なし)
        }
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.成功()
        self.表示中のシート = nil
    }
    func この駒を選択する(_ 今選択した場所: 駒の場所) {
        if !self.増減モード中 {
            switch self.選択中の駒 {
                case .なし:
                    if self.局面.ここに駒がある(今選択した場所) {
                        withAnimation(.default.speed(2.5)) {
                            self.選択中の駒の値を変更する(今選択した場所)
                        }
                        self.フィードバック.軽め()
                    }
                default:
                    if self.選択中の駒 == 今選択した場所 {
                        self.選択中の駒の値を変更する(.なし)
                    } else if self.局面.これとこれは同じ陣営(self.選択中の駒, 今選択した場所) {
                        self.選択中の駒の値を変更する(今選択した場所)
                        self.フィードバック.軽め()
                    } else {
                        switch 今選択した場所 {
                            case .盤駒(let 位置):
                                if !self.局面.ここからここへは移動不可(self.選択中の駒, .盤上(位置)) {
                                    self.盤上に駒を移動させる(.盤上(位置))
                                }
                            case .手駒(let 陣営, _):
                                self.こちらの手駒エリアを選択する(陣営)
                            default:
                                break
                        }
                    }
            }
        } else {
            switch 今選択した場所 {
                case .盤駒(_):
                    self.増減モードでこの盤駒を消す(今選択した場所)
                case .手駒(let 陣営, _):
                    self.表示中のシート = .手駒増減(陣営)
                    self.フィードバック.軽め()
                default:
                    break
            }
        }
    }
    func こちらの手駒エリアを選択する(_ 陣営: 王側か玉側か) {
        guard self.選択中の駒 != .なし else { return }
        withAnimation(.default.speed(2)) {
            if self.局面.ここからここへは移動不可(選択中の駒, .盤外(陣営)) {
                self.選択中の駒の値を変更する(.なし)
                self.フィードバック.軽め()
            } else {
                do {
                    try self.局面.駒を移動させる(選択中の駒, .盤外(陣営))
                    self.選択中の駒の値を変更する(.なし)
                    self.SharePlay中なら現在の局面を参加者に送信する()
                    self.フィードバック.強め()
                } catch {
                    assertionFailure()
                }
            }
        }
    }
    func 今移動した駒を成る() {
        if case .盤駒(let 位置) = self.局面.直近の操作 {
            self.この駒を裏返す(位置)
        }
    }
    var 成駒確認メッセージ: String {
        var 値: String
        guard case .盤駒(let 位置) = self.局面.直近の操作,
              let 職名 = self.局面.盤駒[位置]?.職名 else { return "⚠︎" }
        if self.english表記 {
            値 = 職名.english生駒表記 + " → " + (職名.english成駒表記 ?? "⚠︎")
        } else {
            値 = 職名.rawValue + " → " + (職名.成駒表記 ?? "⚠︎")
        }
#if os(visionOS)
        if self.グループセッション?.state == .joined {
            値 += "\n" + String(localized: "(このダイアログは相手には見えていません)")
        }
#endif
        return 値
    }
    func 盤面を初期化する() {
        withAnimation { self.局面.初期化する() }
        self.選択中の駒の値を変更する(.なし)
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.エラー()
        self.表示中のシート = nil
    }
    func 駒の選択を解除する() {
        self.選択中の駒の値を変更する(.なし)
    }
    func 増減モードを開始する() {
        self.増減モード中 = true
        self.フィードバック.成功()
        self.表示中のシート = nil
    }
    func 増減モードを終了する() {
        self.増減モード中 = false
        self.フィードバック.成功()
    }
    func 増減モードでこの手駒を一個増やす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        guard self.局面.増減モードでこの手駒を増やすことが出来る(陣営, 職名) else { return }
        self.局面.増減モードでこの手駒を一個増やす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.軽め()
    }
    func 増減モードでこの手駒を一個減らす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        guard self.局面.増減モードでこの手駒を減らすことが出来る(陣営, 職名) else { return }
        self.局面.増減モードでこの手駒を一個減らす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.軽め()
    }
    func 一手戻す() {
        guard let 一手前の局面 = self.局面.一手前の局面 else { return }
        self.選択中の駒の値を変更する(.なし)
        self.局面.現在の局面として適用する(一手前の局面)
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.成功()
        self.表示中のシート = nil
    }
    func 選択中の駒を裏返す() {
        guard case .盤駒(let 位置) = self.選択中の駒 else { return }
        self.選択中の駒の値を変更する(.なし)
        self.この駒を裏返す(位置)
        self.表示中のシート = nil
    }
    // ==== private ====
    private func 盤上に駒を移動させる(_ 移動先: 駒の移動先パターン) {
        withAnimation(.default.speed(2)) {
            do {
                try self.局面.駒を移動させる(self.選択中の駒, 移動先)
                self.SharePlay中なら現在の局面を参加者に送信する()
                self.駒移動後の成駒について対応する(self.選択中の駒, 移動先)
                self.選択中の駒の値を変更する(.なし)
                self.フィードバック.強め()
            } catch {
                assertionFailure()
            }
        }
    }
    private func 駒移動後の成駒について対応する(_ 出発場所: 駒の場所, _ 置いた場所: 駒の移動先パターン) {
        if case .盤上(let 位置) = 置いた場所 {
            if self.局面.この駒移動で成る事が可能(.盤駒(位置), 出発場所) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.成駒確認アラートを表示 = true
                }
            }
        }
    }
    private func 選択中の駒の値を変更する(_ 変更後の値: 駒の場所) {
        self.選択中の駒 = 変更後の値
        self.SharePlay中なら現在の選択中の駒を参加者に送信する()
#if os(visionOS)
        self.駒を持ち上げたのは自分 = (変更後の値 != .なし)
#endif
    }
    private func この駒を裏返す(_ 位置: Int) {
        if self.局面.この駒は成る事ができる(位置) {
            self.局面.この駒を裏返す(位置)
            self.SharePlay中なら現在の局面を参加者に送信する()
            self.フィードバック.強め()
        }
    }
    private func 増減モードでこの盤駒を消す(_ 場所: 駒の場所) {
        guard case .盤駒(let 位置) = 場所 else { return }
        withAnimation(.default.speed(2)) {
            self.局面.増減モードでこの盤駒を消す(位置)
        }
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.軽め()
    }
}

//MARK: - ==== 局面の読み込みや復元 ====
extension アプリモデル {
    func 任意の局面を現在の局面として適用する(_ 局面: 局面モデル) { //履歴, ブックマーク
        self.表示中のシート = nil
        withAnimation { self.局面.現在の局面として適用する(局面) }
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.フィードバック.成功()
    }
    func 現在の局面をブックマークする() {
        self.局面.現在の局面をブックマークする()
        self.フィードバック.軽め()
    }
    @objc @MainActor
    func iCloudによる外部からの履歴変更を適用する(_ notification: Notification) {
        guard ICloudデータ.このキーが変更された(key: "履歴", notification) else { return }
        Task { @MainActor in
            guard let 外部で変更された局面の最新 = 局面モデル.履歴.last else { return }
            self.局面 = 外部で変更された局面の最新
            self.SharePlay中なら現在の局面を参加者に送信する()
            self.駒の選択を解除する()
        }
    }
}

#if os(iOS) || os(visionOS) //UIApplicationDelegate, ドラッグ&ドロップ, SharePlay, テキスト書き出し読み込み機能
extension アプリモデル: UIApplicationDelegate {}

//MARK: - ==== ドラッグ関連 ====
extension アプリモデル {
    func この駒をドラッグし始める(_ 場所: 駒の場所) -> NSItemProvider {
        self.選択中の駒の値を変更する(.なし)
        self.フィードバック.軽め()
        self.ドラッグ中の駒 = .アプリ内の駒(場所)
        return self.ドラッグ対象となるアイテムを用意する()
    }
    private func ドラッグ対象となるアイテムを用意する() -> NSItemProvider {
        let テキスト = self.現在の盤面をテキストに変換する()
        let itemProvider = NSItemProvider(object: テキスト as NSItemProviderWriting)
        itemProvider.suggestedName = "アプリ内でのコマ移動"
        return itemProvider
    }
}

//MARK: - ==== ドロップ関連 ====
extension アプリモデル {
    func ここにドロップする(_ 置いた場所: 駒の移動先パターン, _ dropInfo: DropInfo) -> Bool {
        do {
            switch self.ドラッグ中の駒 {
                case .アプリ内の駒(let 出発場所):
                    try self.局面.駒を移動させる(出発場所, 置いた場所)
                    self.駒移動後の成駒について対応する(出発場所, 置いた場所)
                    self.ドラッグ中の駒 = .無し
                    self.SharePlay中なら現在の局面を参加者に送信する()
                    self.フィードバック.ドロップ()
                case .アプリ外のコンテンツ:
                    let itemProviders = dropInfo.itemProviders(for: [.utf8PlainText])
                    self.このアイテムを盤面に反映する(itemProviders)
                case .無し:
                    return false
            }
            return true
        } catch 局面モデル.駒移動エラー.無効 {
            return false
        } catch {
            print("🚨", error.localizedDescription)
            assertionFailure()
            return false
        }
    }
    func ここはドロップ可能か確認する(_ 移動先: 駒の移動先パターン) -> DropProposal? {
        guard case .アプリ内の駒(let ドラッグし始めた場所) = self.ドラッグ中の駒 else { return nil }
        if self.局面.ここからここへは移動不可(ドラッグし始めた場所, 移動先) {
            return DropProposal(operation: .cancel)
        } else {
            return nil
        }
    }
    func 有効なドロップかチェックする(_ dropInfo: DropInfo) -> Bool {
        let itemProviders = dropInfo.itemProviders(for: [.utf8PlainText])
        guard let itemProvider = itemProviders.first else { return false }
#if targetEnvironment(macCatalyst)
        if !MacCatalyst調整.このアイテムはアプリ内でのドラッグ(itemProvider) {
            self.ドラッグ中の駒 = .アプリ外のコンテンツ
        }
        return true
#else
        if let suggestedName = itemProvider.suggestedName {
            if suggestedName != "アプリ内でのコマ移動" {
                self.ドラッグ中の駒 = .アプリ外のコンテンツ
            }
        } else {
            self.ドラッグ中の駒 = .アプリ外のコンテンツ
        }
        return true
#endif
    }
}

//MARK: - ==== SharePlay ====
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
    private func SharePlay中なら現在の局面を参加者に送信する() {
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
    private func SharePlay中なら現在の選択中の駒を参加者に送信する() {
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
    //Sample code
    //https://developer.apple.com/documentation/groupactivities/drawing_content_in_a_group_session
}

//MARK: - ==== テキスト書き出し読み込み機能 ====
extension アプリモデル {
    func 現在の盤面をテキストに変換する() -> String {
        テキスト連携機能.テキストに変換する(self.局面)
    }
    func テキストを局面に変換して読み込む(_ テキスト: String) throws {
        if let インポートした局面 = テキスト連携機能.局面モデルに変換する(テキスト) {
            self.局面.現在の局面として適用する(インポートした局面)
            self.SharePlay中なら現在の局面を参加者に送信する()
            self.フィードバック.成功()
        } else {
            throw Self.テキスト読み込みエラー.局面変換失敗
        }
    }
    func 現在の局面をテキストとしてコピー() {
        UIPasteboard.general.string = self.現在の盤面をテキストに変換する()
        self.フィードバック.成功()
    }
    func テキストを局面としてペースト() throws {
        guard let テキスト = UIPasteboard.general.string else {
            throw Self.テキスト読み込みエラー.ペーストされたものがテキストではない
        }
        try self.テキストを局面に変換して読み込む(テキスト)
    }
    private enum テキスト読み込みエラー: Error {
        case 局面変換失敗, ペーストされたものがテキストではない
    }
    private func このアイテムを盤面に反映する(_ itemProviders: [NSItemProvider]) {
        Task { @MainActor in
            do {
                guard let itemProvider = itemProviders.first else { return }
                let secureCodingObject = try await itemProvider.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier)
                guard let データ = secureCodingObject as? Data else { return }
                guard let テキスト = String(data: データ, encoding: .utf8) else { return }
                try self.テキストを局面に変換して読み込む(テキスト)
            } catch {
                print(#function, error)
            }
            self.ドラッグ中の駒 = .無し
        }
    }
}
#endif

#if os(watchOS) || os(tvOS)
extension アプリモデル {
    private func SharePlay中なら現在の選択中の駒を参加者に送信する() {
        //Unsupport on watchOS, tvOS
    }
    private func SharePlay中なら現在の局面を参加者に送信する() {
        //Unsupport on watchOS, tvOS
    }
}
#endif
