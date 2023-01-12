import Combine
import SwiftUI
import UniformTypeIdentifiers
import GroupActivities

@MainActor
class 📱アプリモデル: ObservableObject {
    
    @Published private(set) var 局面: 局面モデル
    
    @AppStorage("English表記") var 🚩English表記: Bool = false
    @AppStorage("直近操作強調表示機能オフ") var 🚩直近操作強調表示機能オフ: Bool = false
    @AppStorage("上下反転") var 🚩上下反転: Bool = false
    
    @Published var 🚩メニューを表示: Bool = false
    @Published var 🚩履歴を表示: Bool = false
    @Published var 🚩駒を整理中: Bool = false
    
    @Published var ドラッグ中の駒: ドラッグ対象 = .無し
    
    func この盤駒の表記(_ 位置: Int) -> String {
        self.局面.盤上のこの駒の表記(位置, self.🚩English表記) ?? "🐛"
    }
    
    func この手駒の表記(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> String {
        self.局面.この手駒の表記(陣営, 職名, self.🚩English表記)
    }
    
    func この盤駒は操作直後(_ 画面上での左上からの位置: Int) -> Bool {
        let 元々の位置 = self.🚩上下反転 ? (80 - 画面上での左上からの位置) : 画面上での左上からの位置
        return self.局面.直近の操作 == .盤駒の移動や成り(元々の位置)
    }
    
    func この手駒は操作直後(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> Bool {
        self.局面.直近の操作 == .手駒の増減(陣営, 職名)
    }
    
    func 直近操作の強調表示をクリア() {
        self.局面.直近操作情報を消す()
        self.履歴追加やSharePlay同期を行う()
        振動フィードバック()
    }
    
    func この駒を裏返す(_ 位置: Int) {
        if self.局面.盤駒[位置]?.職名.成駒表記 != nil {
            self.局面.この駒を裏返す(位置)
            self.履歴追加やSharePlay同期を行う()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    func 盤面を初期化する() {
        self.局面.初期化する()
        self.履歴追加やSharePlay同期を行う()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func 編集モードでこの手駒を一個増やす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.編集モードでこの手駒を一個増やす(陣営, 職名)
        self.履歴追加やSharePlay同期を行う()
        振動フィードバック()
    }

    func 編集モードでこの手駒を一個減らす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.編集モードでこの手駒を一個減らす(陣営, 職名)
        self.履歴追加やSharePlay同期を行う()
        振動フィードバック()
    }

    func 編集モードでこの盤駒を消す(_ 位置: Int) {
        self.局面.編集モードでこの盤駒を消す(位置)
        self.履歴追加やSharePlay同期を行う()
        振動フィードバック()
    }
    
    // ======== ドラッグ処理 ========
    func この盤駒をドラッグし始める(_ 位置: Int) -> NSItemProvider {
        self.ドラッグ中の駒 = .盤駒(位置)
        return self.ドラッグ対象となるアイテムを用意する()
    }
    
    func この手駒をドラッグし始める(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> NSItemProvider {
        self.ドラッグ中の駒 = .手駒(陣営, 職名)
        return self.ドラッグ対象となるアイテムを用意する()
    }
    
    private func ドラッグ対象となるアイテムを用意する() -> NSItemProvider {
        let テキスト = self.現在の盤面をテキストに変換する()
        let ⓘtemProvider = NSItemProvider(object: テキスト as NSItemProviderWriting)
        ⓘtemProvider.suggestedName = "アプリ内でのコマ移動"
        return ⓘtemProvider
    }
    
    // ================================================================================
    // ============================= 以下、ドロップDelegate =============================
    func 盤上のここにドロップする(_ 置いた位置: Int, _ ⓘnfo: DropInfo) -> Bool {
        do {
            switch self.ドラッグ中の駒 {
                case .盤駒(let 出発地点):
                    try self.局面.盤駒を移動させる(出発地点, 置いた位置)
                    self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                case .手駒(let 陣営, let 職名):
                    try self.局面.手駒を盤上へ移動させる(陣営, 職名, 置いた位置)
                    self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                case .アプリ外のコンテンツ:
                    let ⓘtemProviders = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
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
    
    func 盤外のこちら側にドロップする(_ ドロップされた陣営: 王側か玉側か, _ ⓘnfo: DropInfo) -> Bool {
        do {
            switch self.ドラッグ中の駒 {
                case .盤駒(let 出発地点):
                    try self.局面.盤駒を盤外へ移動させる(出発地点, ドロップされた陣営)
                    self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                case .手駒(let 陣営, let 職名):
                    self.局面.自分の手駒を敵の手駒側に移動させる(陣営, 職名, ドロップされた陣営)
                    self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                case .アプリ外のコンテンツ:
                    let ⓘtemProviders = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
                    self.このアイテムを盤面に反映する(ⓘtemProviders)
                case .無し:
                    return false
            }
            return true
        } catch {
            print("🚨", error.localizedDescription)
            assertionFailure()
            return false
        }
    }
    
    private func 駒を移動し終わったらログを更新してフィードバックを発生させる() {
        self.ドラッグ中の駒 = .無し
        self.履歴追加やSharePlay同期を行う()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    func 盤上のここはドロップ可能か確認する(_ 検証位置: Int) -> DropProposal? {
        switch self.ドラッグ中の駒 {
            case .盤駒(let ドラッグした盤駒の元々の位置):
                if 検証位置 == ドラッグした盤駒の元々の位置 {
                    return DropProposal(operation: .cancel)
                }
                if self.局面.盤駒[検証位置]?.陣営 == self.局面.盤駒[ドラッグした盤駒の元々の位置]?.陣営 {
                    return DropProposal(operation: .cancel)
                }
            case .手駒(_, _):
                if self.局面.盤駒[検証位置] != nil {
                    return .init(operation: .cancel)
                }
            case .アプリ外のコンテンツ, .無し:
                return nil
        }
        return nil
    }
    
    func 盤外のここはドロップ可能か確認する(_ ドロップしようとしている陣営: 王側か玉側か) -> DropProposal? {
        switch self.ドラッグ中の駒 {
            case .手駒(let 元々の陣営, _):
                if ドロップしようとしている陣営 == 元々の陣営 {
                    return DropProposal(operation: .cancel)
                } else {
                    return nil
                }
            default:
                return nil
        }
    }
        
    func 有効なドロップかチェックする(_ ⓘnfo: DropInfo) -> Bool {
        let ⓘtemProviders = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
        guard let ⓘtemProvider = ⓘtemProviders.first else { return false }
        if let ⓢuggestedName = ⓘtemProvider.suggestedName {
            if ⓢuggestedName != "アプリ内でのコマ移動" {
                print("アプリ外部からのアイテムです")
                print("itemProvider.suggestedName: ", ⓢuggestedName)
                self.ドラッグ中の駒 = .アプリ外のコンテンツ
            }
        } else {
            print("アプリ外部からのアイテムです")
            self.ドラッグ中の駒 = .アプリ外のコンテンツ
        }
        return true
    }
    
    // ==============================================================================
    // ============================= 以下、ログの更新や保存 =============================
    init() {
        if データ管理_ver_1_2_2.以前のデータがあるか {
            self.局面 = データ管理_ver_1_2_2.以前アプリ起動した際のログを読み込む()
            データ管理_ver_1_2_2.以前のデータを削除する()
        } else {
            if let 前回の局面 = 局面モデル.履歴.last {
                self.局面 = 前回の局面
            } else {
                self.局面 = .初期セット
            }
        }
    }
    
    private func 履歴追加やSharePlay同期を行う(履歴追加: Bool = true, SharePlay同期: Bool = true) {
        if 履歴追加 { self.局面.現在の局面を履歴に追加する() }
        if SharePlay同期 { self.SharePlay中なら現在の局面を参加者に送信する() }
    }
    
    func 履歴を復元する(_ 過去の局面: 局面モデル) {
        self.🚩メニューを表示 = false
        self.🚩履歴を表示 = false
        self.局面 = 過去の局面
        self.局面.現時刻を更新日時として設定する()
        self.履歴追加やSharePlay同期を行う()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    // ================================================================
    // ======================== 以下、SharePlay ========================
    private var ⓢubscriptions = Set<AnyCancellable>()
    private var ⓣasks = Set<Task<Void, Never>>()
    @Published var ⓖroupSession: GroupSession<🄶roupActivity>?
    private var ⓜessenger: GroupSessionMessenger?
    
    func 新規GroupSessionを受信したら設定する() async {
        for await ⓝewSession in 🄶roupActivity.sessions() {
            self.局面.初期化する()
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
                .store(in: &ⓢubscriptions)
            ⓝewSession.$activeParticipants
                .sink { ⓐctiveParticipants in
                    let ⓝewParticipant = ⓐctiveParticipants.subtracting(ⓝewSession.activeParticipants)
                    Task {
                        try? await ⓝewMessenger.send(self.局面, to: .only(ⓝewParticipant))
                    }
                }
                .store(in: &ⓢubscriptions)
            let ⓡeceiveDataTask = Task {
                for await (ⓜessage, _) in ⓝewMessenger.messages(of: 局面モデル.self) {
                    if let 受信データの更新日時 = ⓜessage.更新日時 {
                        if let 現在の局面の更新日時 = self.局面.更新日時 {
                            if 受信データの更新日時 > 現在の局面の更新日時 {
                                withAnimation(.default.speed(2.0)) { self.局面 = ⓜessage }
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                self.履歴追加やSharePlay同期を行う(SharePlay同期: false)
                            }
                        } else {
                            withAnimation(.default.speed(2.0)) { self.局面 = ⓜessage }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            self.履歴追加やSharePlay同期を行う(SharePlay同期: false)
                        }
                    }
                }
            }
            ⓣasks.insert(ⓡeceiveDataTask)
            ⓝewSession.join()
        }
    }
    
    private func リセットする() {
        self.ⓜessenger = nil
        self.ⓣasks.forEach { $0.cancel() }
        self.ⓣasks = []
        self.ⓢubscriptions = []
        if self.ⓖroupSession != nil {
            self.ⓖroupSession?.leave()
            self.ⓖroupSession = nil
            🄶roupActivity.アクティビティを起動する()
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
    
    var セッションステート表記: String {
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
    
    // ==============================================================================
    // ======================== 以下、テキスト書き出し読み込み機能 ========================
    func 現在の盤面をテキストに変換する() -> String {
        📃テキスト連携機能.テキストに変換する(self.局面)
    }
    
    private func このアイテムを盤面に反映する(_ ⓘtemProviders: [NSItemProvider]) {
        Task { @MainActor in
            do {
                guard let ⓘtemProvider = ⓘtemProviders.first else { return }
                let ⓢecureCodingObject = try await ⓘtemProvider.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier)
                guard let データ = ⓢecureCodingObject as? Data else { return }
                guard let テキスト = String(data: データ, encoding: .utf8) else { return }
                if let インポートした局面 = 📃テキスト連携機能.局面モデルに変換する(テキスト) {
                    self.局面 = インポートした局面
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                self.ドラッグ中の駒 = .無し
                self.履歴追加やSharePlay同期を行う()
            } catch {
                print(#function, error)
            }
        }
    }
}

enum 🚨エラー: Error {
    case 要修正
}
