import Combine
import SwiftUI
import UniformTypeIdentifiers
import GroupActivities

@MainActor
class 📱アプリモデル: ObservableObject {
    
    @Published private(set) var 局面: 局面モデル
    
    @AppStorage("English表記") var 🚩English表記: Bool = false
    @AppStorage("移動直後強調表示機能オフ") var 🚩移動直後強調表示機能オフ: Bool = false
    @AppStorage("上下反転") var 🚩上下反転: Bool = false
    
    @Published var 🚩メニューを表示: Bool = false
    @Published var 🚩履歴を表示: Bool = false
    @Published var 🚩駒を整理中: Bool = false
    
    @Published var ドラッグした盤上の駒の元々の位置: Int? = nil
    private var ドラッグした手駒: 盤外の駒? = nil
    
    var 現状: ドラッグ状況 = .何もドラッグしてない {
        didSet {
            switch 現状 {
                case .盤上の駒をドラッグしている:
                    ドラッグした手駒 = nil
                case .手駒をドラッグしている:
                    ドラッグした盤上の駒の元々の位置 = nil
                case .アプリ外部からドラッグしている, .何もドラッグしてない:
                    ドラッグした盤上の駒の元々の位置 = nil
                    ドラッグした手駒 = nil
            }
        }
    }
    
    func 盤上のこの駒の表記(_ 位置: Int) -> String {
        self.局面.盤上のこの駒の表記(位置, self.🚩English表記) ?? "🐛"
    }
    
    func この手駒の表記(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> String {
        self.局面.この手駒の表記(陣営, 職名, self.🚩English表記)
    }
    
    func 取った駒として強調表示(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> Bool {
        if !self.🚩移動直後強調表示機能オフ {
            if let 強調する手駒 = self.局面.盤駒の通常移動直後の駒?.取った手駒 {
                if let 移動直後の位置 = self.局面.盤駒の通常移動直後の駒?.盤上の位置 {
                    if 陣営 == self.局面.盤駒[移動直後の位置]?.陣営 {
                        if 職名 == 強調する手駒 {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    func この駒は通常移動直後(_ 画面上での左上からの位置: Int) -> Bool {
        let 元々の位置 = self.🚩上下反転 ? (80 - 画面上での左上からの位置) : 画面上での左上からの位置
        return self.局面.盤駒の通常移動直後の駒?.盤上の位置 == 元々の位置
    }
    
    func 盤駒の通常移動直後の強調表示をクリア() {
        self.局面.盤駒通常移動直後情報を消す()
        self.SharePlay中なら現在の局面を参加者に送信する()
        振動フィードバック()
    }
    
    func この駒を裏返す(_ 位置: Int) {
        if self.局面.盤駒[位置]?.成り != nil {
            self.局面.この駒を裏返す(位置)
            self.現在の局面を履歴に追加する()
            self.SharePlay中なら現在の局面を参加者に送信する()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    func 盤面を初期化する() {
        self.局面.初期化する()
        self.SharePlay中なら現在の局面を参加者に送信する()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func この手駒を一個増やす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.この手駒を一個増やす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        振動フィードバック()
    }

    func この手駒を一個減らす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.この手駒を一個減らす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        振動フィードバック()
    }

    func この盤駒を消す(_ 位置: Int) {
        self.局面.この盤駒を消す(位置)
        self.SharePlay中なら現在の局面を参加者に送信する()
        振動フィードバック()
    }
    
    // ======== ドラッグ処理 ========
    func この盤上の駒をドラッグし始める(_ 位置: Int) -> NSItemProvider {
        self.ドラッグした盤上の駒の元々の位置 = 位置
        self.現状 = .盤上の駒をドラッグしている
        return self.ドラッグ対象となるアイテムを用意する()
    }
    
    func この手駒をドラッグし始める(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> NSItemProvider {
        self.ドラッグした手駒 = 盤外の駒(陣営, 職名)
        self.現状 = .手駒をドラッグしている
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
            switch self.現状 {
                case .盤上の駒をドラッグしている:
                    guard let 出発地点 = self.ドラッグした盤上の駒の元々の位置 else { throw 🚨エラー.要修正 }
                    try self.局面.盤駒を移動させる(出発地点, 置いた位置)
                    self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                case .手駒をドラッグしている:
                    guard let 駒 = self.ドラッグした手駒 else { throw 🚨エラー.要修正 }
                    try self.局面.手駒を盤上へ移動させる(駒, 置いた位置)
                    self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                case .アプリ外部からドラッグしている:
                    let ⓘtemProviders = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
                    self.このアイテムを盤面に反映する(ⓘtemProviders)
                case .何もドラッグしてない:
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
            switch self.現状 {
                case .盤上の駒をドラッグしている:
                    guard let 出発地点 = self.ドラッグした盤上の駒の元々の位置 else { throw 🚨エラー.要修正 }
                    try self.局面.盤駒を盤外へ移動させる(出発地点, ドロップされた陣営)
                    self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                case .手駒をドラッグしている:
                    guard let 駒 = self.ドラッグした手駒 else { throw 🚨エラー.要修正 }
                    self.局面.自分の手駒を敵の手駒側に移動させる(駒, ドロップされた陣営)
                    self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                case .アプリ外部からドラッグしている:
                    let ⓘtemProviders = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
                    self.このアイテムを盤面に反映する(ⓘtemProviders)
                case .何もドラッグしてない:
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
        self.現状 = .何もドラッグしてない
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.現在の局面を履歴に追加する()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    func 盤上のここはドロップ可能か確認する(_ 位置: Int) -> DropProposal? {
        switch self.現状 {
            case .盤上の駒をドラッグしている:
                if 位置 == self.ドラッグした盤上の駒の元々の位置 {
                    return DropProposal(operation: .cancel)
                }
                if let 元々の位置 = self.ドラッグした盤上の駒の元々の位置 {
                    if self.局面.盤駒[位置]?.陣営 == self.局面.盤駒[元々の位置]?.陣営 {
                        return DropProposal(operation: .cancel)
                    }
                }
            case .手駒をドラッグしている:
                if self.局面.盤駒[位置] != nil {
                    return .init(operation: .cancel)
                }
            case .アプリ外部からドラッグしている, .何もドラッグしてない:
                return nil
        }
        return nil
    }
    
    func 盤外のここはドロップ可能か確認する(_ ドロップしようとしている陣営: 王側か玉側か) -> DropProposal? {
        if self.現状 == .手駒をドラッグしている {
            if let 駒 = self.ドラッグした手駒 {
                if ドロップしようとしている陣営 == 駒.陣営 {
                    return DropProposal(operation: .cancel)
                }
            }
        }
        return nil
    }
        
    func 有効なドロップかチェックする(_ ⓘnfo: DropInfo) -> Bool {
        let ⓘtemProviders = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
        guard let ⓘtemProvider = ⓘtemProviders.first else { return false }
        if let ⓢuggestedName = ⓘtemProvider.suggestedName {
            if ⓢuggestedName != "アプリ内でのコマ移動" {
                print("アプリ外部からのアイテムです")
                print("itemProvider.suggestedName: ", ⓢuggestedName)
                self.現状 = .アプリ外部からドラッグしている
            }
        } else {
            print("アプリ外部からのアイテムです")
            self.現状 = .アプリ外部からドラッグしている
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
    
    private func 現在の局面を履歴に追加する() {
        self.局面.現在の局面を履歴に追加する()
    }
    
    func 履歴を復元する(_ 過去の局面: 局面モデル) {
        self.局面 = 過去の局面
        self.局面.現時刻を更新日時として設定する()
        self.SharePlay中なら現在の局面を参加者に送信する()
        self.🚩メニューを表示 = false
        self.🚩履歴を表示 = false
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
                                withAnimation { self.局面 = ⓜessage }
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                self.現在の局面を履歴に追加する()
                            }
                        } else {
                            withAnimation { self.局面 = ⓜessage }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            self.現在の局面を履歴に追加する()
                        }
                    }
                }
            }
            ⓣasks.insert(ⓡeceiveDataTask)
            ⓝewSession.join()
        }
    }
    
    func リセットする() {
        self.ⓜessenger = nil
        self.ⓣasks.forEach { $0.cancel() }
        self.ⓣasks = []
        self.ⓢubscriptions = []
        if self.ⓖroupSession != nil {
            self.ⓖroupSession?.leave()
            self.ⓖroupSession = nil
            🄶roupActivity.アクティビティを開始する()
        }
    }
    
    func SharePlay中なら現在の局面を参加者に送信する() {
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
                self.現状 = .何もドラッグしてない
                self.SharePlay中なら現在の局面を参加者に送信する()
            } catch {
                print(#function, error)
            }
        }
    }
}

enum ドラッグ状況 {
    case 盤上の駒をドラッグしている
    case 手駒をドラッグしている
    case アプリ外部からドラッグしている
    case 何もドラッグしてない
}

enum 🚨エラー: Error {
    case 要修正
}
