import Combine
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class 📱アプリモデル: ObservableObject {
    
    @Published private(set) var 局面: 局面モデル
    
    @AppStorage("English表記") var 🚩English表記: Bool = false
    @AppStorage("移動直後強調表示機能オフ") var 🚩移動直後強調表示機能オフ: Bool = false
    @AppStorage("上下反転") var 🚩上下反転: Bool = false
    
    @Published var 🚩メニューを表示: Bool = false
    @Published var 🚩駒を整理中: Bool = false
    
    @Published var ドラッグした盤上の駒の元々の位置: Int? = nil
    private var ドラッグした持ち駒: 盤外の駒? = nil
    
    var 現状: ドラッグ状況 = .何もドラッグしてない {
        didSet {
            switch 現状 {
                case .盤上の駒をドラッグしている:
                    ドラッグした持ち駒 = nil
                case .持ち駒をドラッグしている:
                    ドラッグした盤上の駒の元々の位置 = nil
                case .アプリ外部からドラッグしている, .何もドラッグしてない:
                    ドラッグした盤上の駒の元々の位置 = nil
                    ドラッグした持ち駒 = nil
            }
        }
    }
    
    func この盤上の駒の表記(_ 位置: Int) -> String {
        guard let 駒 = self.局面.盤駒[位置] else { return "🐛" }
        let シンボル: String
        if 駒.成り {
            if self.🚩English表記 {
                シンボル = 駒.職名.English成駒表記 ?? "🐛"
            } else {
                シンボル = 駒.職名.成駒表記 ?? "🐛"
            }
        } else {
            if !self.🚩English表記 && (駒.陣営 == .玉側) && (駒.職名 == .王) {
                シンボル = "玉"
            } else {
                if self.🚩English表記 {
                    シンボル = 駒.職名.English生駒表記
                } else {
                    シンボル = 駒.職名.rawValue
                }
            }
        }
        if self.🚩English表記 && (駒.陣営 == .玉側) && (駒.職名 == .銀 || 駒.職名 == .桂) {
            return シンボル + "′" // U+2032 PRIME
        } else {
            return シンボル
        }
    }
    
    func この持ち駒のメタデータ(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> (駒の表記: String, 数: Int, 数の表記: String) {
        var 駒の表記: String
        if !self.🚩English表記 && (陣営 == .玉側) && (職名 == .王) {
            駒の表記 = "玉"
        } else {
            駒の表記 = self.🚩English表記 ? 職名.English生駒表記 : 職名.rawValue
        }
        let 数: Int = self.局面.手駒[陣営]?.個数(職名) ?? 0
        let 数の表記: String = 数 >= 2 ? 数.description : ""
        if !self.🚩移動直後強調表示機能オフ {
            if let 強調する持ち駒 = self.局面.盤駒の通常移動直後の駒?.取った持ち駒 {
                if let 移動直後の位置 = self.局面.盤駒の通常移動直後の駒?.盤上の位置 {
                    if 陣営 == self.局面.盤駒[移動直後の位置]?.陣営 {
                        if 職名 == 強調する持ち駒 {
                            駒の表記 += "︭"
                        }
                    }
                }
            }
        }
        return (駒の表記, 数, 数の表記)
    }
    
    func このコマは通常移動直後(_ 画面上での左上からの位置: Int) -> Bool {
        let 元々の位置 = self.🚩上下反転 ? (80 - 画面上での左上からの位置) : 画面上での左上からの位置
        return self.局面.盤駒の通常移動直後の駒?.盤上の位置 == 元々の位置
    }
    
    func この行のコマは通常移動直後(_ 行: Int) -> Bool {
        if let 駒 = self.局面.盤駒の通常移動直後の駒 {
            let 画面上の位置 = self.🚩上下反転 ? (80 - 駒.盤上の位置) : 駒.盤上の位置
            return 行 == 画面上の位置 / 9
        } else {
            return false
        }
    }
    
    func 盤駒の通常移動直後の強調表示をクリア() {
        self.局面.盤駒通常移動直後情報を消す()
        振動フィードバック()
    }
    
    func この駒を裏返す(_ 位置: Int) {
        if self.局面.盤駒[位置]?.成り != nil {
            self.局面.この駒を裏返す(位置)
            self.ログを更新する()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    func 盤面を初期化する() {
        self.局面.初期化する()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func この手駒を一個増やす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.この手駒を一個増やす(陣営, 職名)
        振動フィードバック()
    }

    func この手駒を一個減らす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.局面.この手駒を一個減らす(陣営, 職名)
        振動フィードバック()
    }

    func この盤駒を消す(_ 位置: Int) {
        self.局面.この盤駒を消す(位置)
        振動フィードバック()
    }
    
    // ======== ドラッグ処理 ========
    func この盤上の駒をドラッグし始める(_ 位置: Int) -> NSItemProvider {
        self.ドラッグした盤上の駒の元々の位置 = 位置
        self.現状 = .盤上の駒をドラッグしている
        return self.ドラッグ対象となるアイテムを用意する()
    }
    
    func この持ち駒をドラッグし始める(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> NSItemProvider {
        self.ドラッグした持ち駒 = 盤外の駒(陣営, 職名)
        self.現状 = .持ち駒をドラッグしている
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
                case .持ち駒をドラッグしている:
                    guard let 駒 = self.ドラッグした持ち駒 else { throw 🚨エラー.要修正 }
                    try self.局面.持ち駒を盤上へ移動させる(駒, 置いた位置)
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
                case .持ち駒をドラッグしている:
                    guard let 駒 = self.ドラッグした持ち駒 else { throw 🚨エラー.要修正 }
                    self.局面.持ち駒を敵の持ち駒に移動させる(駒, ドロップされた陣営)
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
        self.ログを更新する()
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
            case .持ち駒をドラッグしている:
                if self.局面.盤駒[位置] != nil {
                    return .init(operation: .cancel)
                }
            case .アプリ外部からドラッグしている, .何もドラッグしてない:
                return nil
        }
        return nil
    }
    
    func 盤外のここはドロップ可能か確認する(_ ドロップしようとしている陣営: 王側か玉側か) -> DropProposal? {
        if self.現状 == .持ち駒をドラッグしている {
            if let 駒 = self.ドラッグした持ち駒 {
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
        if データ管理_ver_3_0_2.以前のデータがあるか {
            self.局面 = データ管理_ver_3_0_2.以前アプリ起動した際のログを読み込む()
            データ管理_ver_3_0_2.以前のデータを削除する()
        } else {
            if let 前回の局面 = 局面モデル.履歴.last {
                self.局面 = 前回の局面
            } else {
                self.局面 = .初期セット
            }
        }
    }
    
    private func ログを更新する() {//MARK: WIP
        self.局面.現在の局面を履歴に追加する()
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
            } catch {
                print(#function, error)
            }
        }
    }
}

enum 🚨エラー: Error {
    case 要修正
}
