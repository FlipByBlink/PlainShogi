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
    @Published var 🚩成駒確認アラートを表示: Bool = false
    
    init() {
        self.局面 = Self.起動時の局面を読み込む()
    }
    
    //SharePlay
    private var ⓢubscriptions = Set<AnyCancellable>()
    private var ⓣasks = Set<Task<Void, Never>>()
    @Published var ⓖroupSession: GroupSession<👥GroupActivity>?
    private var ⓜessenger: GroupSessionMessenger?
    @Published var 参加人数: Int?
}

//MARK: - ==== 局面関連 ====
extension 📱アプリモデル {
    func この盤駒の表記(_ 位置: Int) -> String {
        self.局面.盤上のこの駒の表記(位置, self.🚩English表記) ?? "🐛"
    }
    func この手駒の表記(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> String {
        self.局面.この手駒の表記(陣営, 職名, self.🚩English表記)
    }
    func この盤駒は操作直後(_ 画面上での左上からの位置: Int) -> Bool {
        let 元々の位置 = self.🚩上下反転 ? (80 - 画面上での左上からの位置) : 画面上での左上からの位置
        return self.局面.直近の操作 == .盤駒(元々の位置)
    }
    func この手駒は操作直後(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> Bool {
        self.局面.直近の操作 == .手駒(陣営, 職名)
    }
    func 直近操作の強調表示をクリア() {
        self.局面.直近操作情報を消す()
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.軽め()
    }
    func この駒を裏返す(_ 位置: Int) {
        if let 駒 = self.局面.盤駒[位置] {
            if 駒.職名.成駒あり {
                self.局面.この駒を裏返す(位置)
                self.SharePlay中なら現在の局面を参加者に送信する()
                💥フィードバック.軽め()
            }
        }
    }
    func 盤面を初期化する() {
        self.局面.初期化する()
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.エラー()
    }
    func 編集モードでこの手駒を一個増やす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.編集モードでこの手駒を一個増やす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.軽め()
    }
    func 編集モードでこの手駒を一個減らす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.編集モードでこの手駒を一個減らす(陣営, 職名)
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.軽め()
    }
    func 編集モードでこの盤駒を消す(_ 位置: Int) {
        self.局面.編集モードでこの盤駒を消す(位置)
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.軽め()
    }
    func 一手戻す(_ 一手前の局面: 局面モデル) {
        self.🚩メニューを表示 = false
        self.局面.現在の局面として適用する(一手前の局面)
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.成功()
    }
}

//MARK: - ==== ドラッグ処理 ====
extension 📱アプリモデル {
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
}

//MARK: - ==== ドロップDelegate ====
extension 📱アプリモデル {
    func 盤上のここにドロップする(_ 置いた位置: Int, _ ⓘnfo: DropInfo) -> Bool {
        do {
            switch self.ドラッグ中の駒 {
                case .盤駒(let 出発地点):
                    try self.局面.盤駒を移動させる(出発地点, 置いた位置)
                    if self.局面.この駒の成りについて判断すべき(置いた位置, 出発地点) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.🚩成駒確認アラートを表示 = true
                        }
                    }
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
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.軽め()
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
                    return DropProposal(operation: .cancel)
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
            print("itemProvider.suggestedNameがありません")
            self.ドラッグ中の駒 = .アプリ外のコンテンツ
        }
        return true
    }
}

//MARK: - ==== 局面の読み込みや復元 ====
extension 📱アプリモデル {
    static func 起動時の局面を読み込む() -> 局面モデル {
        if データ管理_ver_1_2_2.以前のデータがあるか {
            let 前回の局面 = データ管理_ver_1_2_2.以前アプリ起動した際のログを読み込む()
            データ管理_ver_1_2_2.以前のデータを削除する()
            return 前回の局面
        } else {
            if let 前回の局面 = 局面モデル.履歴.last {
                return 前回の局面
            } else {
                return .初期セット
            }
        }
    }
    func 履歴を復元する(_ 過去の局面: 局面モデル) {
        self.🚩メニューを表示 = false
        self.🚩履歴を表示 = false
        self.局面.現在の局面として適用する(過去の局面)
        self.SharePlay中なら現在の局面を参加者に送信する()
        💥フィードバック.成功()
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
    private func このアイテムを盤面に反映する(_ ⓘtemProviders: [NSItemProvider]) {
        Task { @MainActor in
            do {
                guard let ⓘtemProvider = ⓘtemProviders.first else { return }
                let ⓢecureCodingObject = try await ⓘtemProvider.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier)
                guard let データ = ⓢecureCodingObject as? Data else { return }
                guard let テキスト = String(data: データ, encoding: .utf8) else { return }
                if let インポートした局面 = 📃テキスト連携機能.局面モデルに変換する(テキスト) {
                    self.局面.現在の局面として適用する(インポートした局面)
                    self.SharePlay中なら現在の局面を参加者に送信する()
                    💥フィードバック.成功()
                }
                self.ドラッグ中の駒 = .無し
            } catch {
                print(#function, error)
            }
        }
    }
}

enum 🚨エラー: Error {
    case 要修正
}
