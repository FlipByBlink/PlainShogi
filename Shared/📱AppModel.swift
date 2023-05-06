import Combine
import SwiftUI
import UniformTypeIdentifiers
#if os(iOS)
import GroupActivities
#endif

@MainActor
class 📱アプリモデル: ObservableObject {
    @Published private(set) var 局面: 局面モデル
    
    @AppStorage("English表記") var 🚩English表記: Bool = false
    @AppStorage("直近操作強調表示機能オフ") var 🚩直近操作強調表示機能オフ: Bool = false
    @AppStorage("上下反転") var 🚩上下反転: Bool = false
    
    @Published var シートを表示: 🪧シートカテゴリ? = nil
    @Published var 成駒確認アラートを表示: Bool = false
    @Published private(set) var 増減モード中: Bool = false
    @Published private(set) var ドラッグ中の駒: ドラッグ対象 = .無し
    @Published private(set) var 選択中の駒: 駒の場所 = .なし
    
    init() {
        self.局面 = Self.起動時の局面を読み込む()
        💾ICloud.addObserver(self, #selector(self.iCloudによる外部からの履歴変更を適用する(_:)))
        💾ICloud.synchronize()
    }
    
#if os(iOS) //SharePlay
    private var ⓢubscriptions = Set<AnyCancellable>()
    private var ⓣasks = Set<Task<Void, Never>>()
    @Published private(set) var ⓖroupSession: GroupSession<👥GroupActivity>?
    private var ⓜessenger: GroupSessionMessenger?
    @Published private(set) var 参加人数: Int?
#endif
}

//MARK: - ==== 局面関連 ====
extension 📱アプリモデル {
    func この駒の表記(_ 場所: 駒の場所) -> String? {
        self.局面.この駒の表記(場所, self.🚩English表記)
    }
    func 手駒増減メニューの駒の表記(_ 職名: 駒の種類, _ 陣営: 王側か玉側か) -> String {
        self.🚩English表記 ? 職名.English生駒表記 : 職名.生駒表記(陣営)
    }
    func この手駒のプレビュー表記(_ 場所: 駒の場所) -> String {
        self.局面.この駒の職名表記(場所, self.🚩English表記) ?? "🐛"
    }
    func この駒は操作直後なので強調表示(_ 場所: 駒の場所) -> Bool {
        (self.局面.直近の操作 == 場所) && !self.🚩直近操作強調表示機能オフ
    }
    func この駒にはアンダーラインが必要(_ 場所: 駒の場所) -> Bool {
        self.局面.この駒にはアンダーラインが必要(場所, self.🚩English表記)
    }
    func この駒は下向き(_ 場所: 駒の場所) -> Bool {
        (self.局面.この駒の陣営(場所) == .玉側) != self.🚩上下反転
    }
    func こちら側のボタンは下向き(_ 陣営: 王側か玉側か) -> Bool {
        (陣営 == .玉側) != self.🚩上下反転
    }
    func こちら側の陣営(_ 立場: 手前か対面か) -> 王側か玉側か {
        switch (立場, self.🚩上下反転) {
            case (.手前, false): return .王側
            case (.対面, false): return .玉側
            case (.手前, true): return .玉側
            case (.対面, true): return .王側
        }
    }
    var 何も強調表示されていない: Bool {
        self.局面.直近の操作 == .なし && self.選択中の駒 == .なし
    }
    var 強調表示常時オフかつ駒が選択されていない: Bool {
        self.🚩直近操作強調表示機能オフ && (self.選択中の駒 == .なし)
    }
    func 強調表示をクリア() {
        withAnimation {
            self.局面.直近操作情報を消す()
            self.選択中の駒 = .なし
        }
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.軽め()
    }
    func この駒を選択する(_ 今選択した場所: 駒の場所) {
        if !self.増減モード中 {
            switch self.選択中の駒 {
                case .なし:
                    if self.局面.ここに駒がある(今選択した場所) {
                        withAnimation(.default.speed(2.5)) {
                            self.選択中の駒 = 今選択した場所
                        }
                        💥フィードバック.軽め()
                    }
                case .盤駒(let 位置) where self.選択中の駒 == 今選択した場所:
                    if self.局面.この駒は成る事ができる(位置) {
                        self.この駒を裏返す(位置)
                    }
                    self.選択中の駒 = .なし
                default:
                    switch 今選択した場所 {
                        case .盤駒(let 位置):
                            if self.局面.ここからここへは移動不可(self.選択中の駒, .盤上(位置)) {
                                if self.局面.これとこれは同じ陣営(self.選択中の駒, 今選択した場所) {
                                    self.選択中の駒 = 今選択した場所
                                    💥フィードバック.軽め()
                                }
                            } else {
                                self.盤上に駒を移動させる(.盤上(位置))
                            }
                        case .手駒(let 陣営, _):
                            self.こちらの手駒エリアを選択する(陣営)
                        default:
                            break
                    }
            }
        } else {
            switch 今選択した場所 {
                case .盤駒(_):
                    self.増減モードでこの盤駒を消す(今選択した場所)
                case .手駒(let 陣営, _):
                    self.シートを表示 = .手駒増減(陣営)
                    💥フィードバック.軽め()
                default:
                    break
            }
        }
    }
    func こちらの手駒エリアを選択する(_ 陣営: 王側か玉側か) {
        guard self.選択中の駒 != .なし else { return }
        withAnimation(.default.speed(2)) {
            if self.局面.ここからここへは移動不可(選択中の駒, .盤外(陣営)) {
                self.選択中の駒 = .なし
            } else {
                do {
                    try self.局面.駒を移動させる(選択中の駒, .盤外(陣営))
                    self.選択中の駒 = .なし
                    self.SharePlay中なら現在の局面を参加者に送信する()
                    💥フィードバック.軽め()
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
        guard case .盤駒(let 位置) = self.局面.直近の操作,
              let 職名 = self.局面.盤駒[位置]?.職名 else { return "🐛" }
        if self.🚩English表記 {
            return 職名.English生駒表記 + " → " + (職名.English成駒表記 ?? "🐛")
        } else {
            return 職名.rawValue + " → " + (職名.成駒表記 ?? "🐛")
        }
    }
    func 盤面を初期化する() {
        withAnimation { self.局面.初期化する() }
        self.選択中の駒 = .なし
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.エラー()
        self.シートを表示 = nil
    }
    func 駒の選択を解除する() {
        self.選択中の駒 = .なし
    }
    func 増減モードを開始する() {
        self.シートを表示 = nil
        self.増減モード中 = true
        💥フィードバック.軽め()
    }
    func 増減モードを終了する() {
        self.増減モード中 = false
        💥フィードバック.成功()
    }
    func 増減モードでこの手駒を一個増やす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.増減モードでこの手駒を一個増やす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.軽め()
    }
    func 増減モードでこの手駒を一個減らす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.増減モードでこの手駒を一個減らす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.軽め()
    }
    func 一手戻す() {
        guard let 一手前の局面 = self.局面.一手前の局面 else { return }
        self.シートを表示 = nil
        self.選択中の駒 = .なし
        self.局面.現在の局面として適用する(一手前の局面)
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.成功()
    }
    // ==== private ====
    private func 盤上に駒を移動させる(_ 移動先: 駒の移動先パターン) {
        withAnimation(.default.speed(2)) {
            do {
                try self.局面.駒を移動させる(self.選択中の駒, 移動先)
                self.SharePlay中なら現在の局面を参加者に送信する()
                self.駒移動後の成駒について対応する(self.選択中の駒, 移動先)
                self.選択中の駒 = .なし
                💥フィードバック.軽め()
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
    private func この駒を裏返す(_ 位置: Int) {
        if self.局面.この駒は成る事ができる(位置) {
            self.局面.この駒を裏返す(位置)
            self.SharePlay中なら現在の局面を参加者に送信する()
            💥フィードバック.軽め()
        }
    }
    private func 増減モードでこの盤駒を消す(_ 場所: 駒の場所) {
        guard case .盤駒(let 位置) = 場所 else { return }
        withAnimation(.default.speed(2)) {
            self.局面.増減モードでこの盤駒を消す(位置)
        }
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.軽め()
    }
}

//MARK: - ==== 局面の読み込みや復元 ====
extension 📱アプリモデル {
    private static func 起動時の局面を読み込む() -> 局面モデル {
#if os(iOS)
        if 🗄️データ移行ver_1_3.ローカルのデータがある {
            let 前回の局面 = 🗄️データ移行ver_1_3.ローカルの直近の局面を読み込む()
            🗄️データ移行ver_1_3.ローカルのデータを削除する()
            return 前回の局面
        } else {
            return 局面モデル.前回の局面 ?? .初期セット
        }
#else
        局面モデル.前回の局面 ?? .初期セット
#endif
    }
    func 念のため局面をリロード() {
        guard let 局面 = 局面モデル.履歴.last else { return }
        self.局面 = 局面
    }
    func 任意の局面を現在の局面として適用する(_ 局面: 局面モデル) { //履歴, ブックマーク
        self.シートを表示 = nil
        withAnimation { self.局面.現在の局面として適用する(局面) }
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.成功()
    }
    func 現在の局面をブックマークする() {
        self.局面.現在の局面をブックマークする()
        💥フィードバック.軽め()
    }
    @objc @MainActor
    func iCloudによる外部からの履歴変更を適用する(_ notification: Notification) {
        print("🖨️", notification.userInfo.debugDescription)
        guard 💾ICloud.このキーが変更された(key: "履歴", notification) else { return }
        Task { @MainActor in
            guard let 外部で変更された局面 = 局面モデル.履歴.last else { return }
            self.局面 = 外部で変更された局面
            self.SharePlay中なら現在の局面を参加者に送信する()
            💥フィードバック.成功()
        }
    }
}

#if os(iOS) //ドラッグ&ドロップ, ShrePlay, テキスト書き出し読み込み機能
//MARK: - ==== ドラッグ関連 ====
extension 📱アプリモデル {
    func この駒をドラッグし始める(_ 場所: 駒の場所) -> NSItemProvider {
        self.選択中の駒 = .なし
        💥フィードバック.軽め()
        self.ドラッグ中の駒 = .アプリ内の駒(場所)
        return self.ドラッグ対象となるアイテムを用意する()
    }
    private func ドラッグ対象となるアイテムを用意する() -> NSItemProvider {
        let テキスト = self.現在の盤面をテキストに変換する()
        let ⓘtemProvider = NSItemProvider(object: テキスト as NSItemProviderWriting)
        ⓘtemProvider.suggestedName = "アプリ内でのコマ移動"
        return ⓘtemProvider
    }
}

//MARK: - ==== ドロップ関連 ====
extension 📱アプリモデル {
    func ここにドロップする(_ 置いた場所: 駒の移動先パターン, _ ⓘnfo: DropInfo) -> Bool {
        do {
            switch self.ドラッグ中の駒 {
                case .アプリ内の駒(let 出発場所):
                    try self.局面.駒を移動させる(出発場所, 置いた場所)
                    self.駒移動後の成駒について対応する(出発場所, 置いた場所)
                    self.ドラッグ中の駒 = .無し
                    self.SharePlay中なら現在の局面を参加者に送信する()
                    💥フィードバック.軽め()
                case .アプリ外のコンテンツ:
                    let ⓘtemProviders = ⓘnfo.itemProviders(for: [.utf8PlainText])
                    self.このアイテムを盤面に反映する(ⓘtemProviders)
                case .無し:
                    return false
            }
            return true
        } catch 局面モデル.🚨駒移動エラー.無効 {
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
    func 有効なドロップかチェックする(_ ⓘnfo: DropInfo) -> Bool {
        let ⓘtemProviders = ⓘnfo.itemProviders(for: [.utf8PlainText])
        guard let ⓘtemProvider = ⓘtemProviders.first else { return false }
#if targetEnvironment(macCatalyst)
        if !🗄️MacCatalyst.このアイテムはアプリ内でのドラッグ(ⓘtemProvider) {
            self.ドラッグ中の駒 = .アプリ外のコンテンツ
        }
        return true
#else
        if let ⓢuggestedName = ⓘtemProvider.suggestedName {
            if ⓢuggestedName != "アプリ内でのコマ移動" {
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
extension 📱アプリモデル {
    func 新規GroupSessionを受信したら設定する() async {
        for await ⓝewSession in 👥GroupActivity.sessions() {
            self.局面 = .初期セット
            self.ⓖroupSession = ⓝewSession
            let ⓝewMessenger = GroupSessionMessenger(session: ⓝewSession)
            self.ⓜessenger = ⓝewMessenger
            ⓝewSession.$state
                .sink { ⓢtate in
                    if case .invalidated = ⓢtate {
                        self.ⓖroupSession = nil
                        self.リセットする()
                    }
                }
                .store(in: &self.ⓢubscriptions)
            ⓝewSession.$activeParticipants
                .sink { ⓐctiveParticipants in
                    let ⓝewParticipants = ⓐctiveParticipants.subtracting(ⓝewSession.activeParticipants)
                    Task {
                        try? await ⓝewMessenger.send(self.局面, to: .only(ⓝewParticipants))
                    }
                    self.参加人数 = ⓐctiveParticipants.count
                }
                .store(in: &self.ⓢubscriptions)
            let ⓡeceiveDataTask = Task {
                for await (ⓜessage, _) in ⓝewMessenger.messages(of: 局面モデル.self) {
                    if let 受信データの更新日時 = ⓜessage.更新日時 {
                        if let 現在の局面の更新日時 = self.局面.更新日時 {
                            if 受信データの更新日時 > 現在の局面の更新日時 {
                                self.SharePlay中に共有相手から送信されたモデルを適用する(ⓜessage)
                            }
                        } else {
                            self.SharePlay中に共有相手から送信されたモデルを適用する(ⓜessage)
                        }
                    }
                }
            }
            self.ⓣasks.insert(ⓡeceiveDataTask)
            ⓝewSession.join()
        }
    }
    private func SharePlay中に共有相手から送信されたモデルを適用する(_ 新規局面: 局面モデル) {
        withAnimation(.default.speed(2.5)) {
            self.局面.更新日時を変更せずにモデルを適用する(新規局面)
        }
        💥フィードバック.強め()
    }
    private func リセットする() {
        self.ⓜessenger = nil
        self.ⓣasks.forEach { $0.cancel() }
        self.ⓣasks = []
        self.ⓢubscriptions = []
        self.参加人数 = nil
        if self.ⓖroupSession != nil {
            self.ⓖroupSession?.leave()
            self.ⓖroupSession = nil
            👥GroupActivity.アクティビティを起動する()
        }
    }
    private func SharePlay中なら現在の局面を参加者に送信する() {
        if let ⓜessenger {
            Task {
                do {
                    try await ⓜessenger.send(self.局面)
                } catch {
                    print("🚨", #function, #line, error.localizedDescription)
                }
            }
        }
    }
    var セッションステート表記: LocalizedStringKey {
        switch self.ⓖroupSession?.state {
            case .waiting: return "待機中"
            case .joined: return "参加中"
            case .invalidated(_): return "無効"
            case .none: return "なし"
            @unknown default:
                assertionFailure()
                return "🐛想定外"
        }
    }
    //Sample code
    //https://developer.apple.com/documentation/groupactivities/drawing_content_in_a_group_session
}

//MARK: - ==== テキスト書き出し読み込み機能 ====
extension 📱アプリモデル {
    func 現在の盤面をテキストに変換する() -> String {
        📃テキスト連携機能.テキストに変換する(self.局面)
    }
    private func テキストを局面に変換して読み込む(_ テキスト: String) {
        if let インポートした局面 = 📃テキスト連携機能.局面モデルに変換する(テキスト) {
            self.局面.現在の局面として適用する(インポートした局面)
            self.SharePlay中なら現在の局面を参加者に送信する()
            💥フィードバック.成功()
        }
    }
    func 現在の局面をテキストとしてコピー() {
        UIPasteboard.general.string = self.現在の盤面をテキストに変換する()
    }
    func テキストを局面としてペースト() {
        guard let テキスト = UIPasteboard.general.string else { return }
        self.テキストを局面に変換して読み込む(テキスト)
    }
    private func このアイテムを盤面に反映する(_ ⓘtemProviders: [NSItemProvider]) {
        Task { @MainActor in
            do {
                guard let ⓘtemProvider = ⓘtemProviders.first else { return }
                let ⓢecureCodingObject = try await ⓘtemProvider.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier)
                guard let データ = ⓢecureCodingObject as? Data else { return }
                guard let テキスト = String(data: データ, encoding: .utf8) else { return }
                self.テキストを局面に変換して読み込む(テキスト)
                self.ドラッグ中の駒 = .無し
            } catch {
                print(#function, error)
            }
        }
    }
}
#endif

#if os(watchOS) || os(tvOS)
extension 📱アプリモデル {
    private func SharePlay中なら現在の局面を参加者に送信する() {
        //Unsupport on watchOS, tvOS
    }
}
#endif
