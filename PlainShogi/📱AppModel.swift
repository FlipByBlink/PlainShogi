import Combine
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class 📱AppModel: ObservableObject {
    
    @Published var 局面: 局面モデル
    
    @AppStorage("English表記") var 🚩English表記: Bool = false
    @AppStorage("動作直後強調表示機能オフ") var 🚩動作直後強調表示機能オフ: Bool = false
    @AppStorage("上下反転") var 🚩上下反転: Bool = false
    
    @Published var 🚩メニューを表示: Bool = false
    @Published var 🚩駒を整理中: Bool = false
    
    @Published var ドラッグした盤上の駒の元々の位置: Int? = nil
    var ドラッグした持ち駒: (陣営: 王側か玉側か, 職名: 駒の種類)? = nil
    
    @Published private(set) var 一般的な動作直後の駒: (盤上の位置: Int, 取った持ち駒: 駒の種類?)? = nil
    
    var 現状: 状況 = .何もドラッグしてない {
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
        let 🚩一般的な動作直後: Bool = (位置 == self.一般的な動作直後の駒?.盤上の位置)
        if self.🚩English表記 && (駒.陣営 == .玉側) && (駒.職名 == .銀 || 駒.職名 == .桂) {
            // ′ U+2032 PRIME
            if !self.🚩動作直後強調表示機能オフ && 🚩一般的な動作直後 {
                return シンボル + "︭" + "′"
            } else {
                return シンボル + "′"
            }
        } else {
            if !self.🚩動作直後強調表示機能オフ && 🚩一般的な動作直後 {
                return シンボル + "︭"
            } else {
                return シンボル
            }
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
        if !self.🚩動作直後強調表示機能オフ {
            if let 強調する持ち駒 = self.一般的な動作直後の駒?.取った持ち駒 {
                if let 動作直後の位置 = self.一般的な動作直後の駒?.盤上の位置 {
                    if 陣営 == self.局面.盤駒[動作直後の位置]?.陣営 {
                        if 職名 == 強調する持ち駒 {
                            駒の表記 += "︭"
                        }
                    }
                }
            }
        }
        return (駒の表記, 数, 数の表記)
    }
    
    func 一般的な動作直後の強調表示をクリアする() {
        self.一般的な動作直後の駒 = nil
        振動フィードバック()
    }
    
    func この駒を裏返す(_ 位置: Int) {
        self.局面.盤駒[位置]?.裏返す()
        self.局面.保存する()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func 盤面を初期化する() {
        self.局面.初期化する()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    // ======== ドラッグ処理 ========
    func この盤上の駒をドラッグし始める(_ 位置: Int) -> NSItemProvider {
        self.ドラッグした盤上の駒の元々の位置 = 位置
        self.現状 = .盤上の駒をドラッグしている
        return self.ドラッグ対象となるアイテムを用意する()
    }
    
    func この持ち駒をドラッグし始める(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> NSItemProvider {
        self.ドラッグした持ち駒 = (陣営, 職名)
        self.現状 = .持ち駒をドラッグしている
        return self.ドラッグ対象となるアイテムを用意する()
    }
    
    func ドラッグ対象となるアイテムを用意する() -> NSItemProvider {
        let テキスト = self.現在の盤面をテキストに変換する()
        let ⓘtemProvider = NSItemProvider(object: テキスト as NSItemProviderWriting)
        ⓘtemProvider.suggestedName = "アプリ内でのコマ移動"
        return ⓘtemProvider
    }
    
    // ================================================================================
    // ============================= 以下、ドロップDelegate =============================
    func 盤上のここにドロップする(_ 置いた位置: Int, _ ⓘnfo: DropInfo) -> Bool {
        switch self.現状 {
            case .盤上の駒をドラッグしている:
                guard let 出発地点 = self.ドラッグした盤上の駒の元々の位置 else { return false }
                if 置いた位置 == 出発地点 { return false }
                
                let 動かした駒 = self.局面.盤駒[出発地点]!
                
                var 取った駒: 駒の種類? = nil
                
                if let 先客 = self.局面.盤駒[置いた位置] {
                    if 先客.陣営 == 動かした駒.陣営 { return false }
                    
                    self.局面.手駒[動かした駒.陣営]?.一個増やす(先客.職名)
                    取った駒 = 先客.職名
                }
                
                self.局面.盤駒.removeValue(forKey: 出発地点)
                self.局面.盤駒.updateValue(動かした駒, forKey: 置いた位置)
                
                self.一般的な動作直後の駒 = (置いた位置, 取った駒)
                
                self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                
            case .持ち駒をドラッグしている:
                guard let 駒 = self.ドラッグした持ち駒 else { return false }
                if self.局面.盤駒[置いた位置] != nil { return false }
                
                self.局面.盤駒.updateValue(盤上の駒(駒.陣営, 駒.職名), forKey: 置いた位置)
                
                self.局面.手駒[駒.陣営]?.一個減らす(駒.職名)
                
                self.一般的な動作直後の駒 = (置いた位置, nil)
                
                self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                
            case .アプリ外部からドラッグしている:
                let ⓘtemProviders = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
                self.このアイテムを盤面に反映する(ⓘtemProviders)
                
            case .何もドラッグしてない:
                return false
        }
        
        return true
    }
    
    func 盤外のこちら側にドロップする(_ ドロップされた陣営: 王側か玉側か, _ ⓘnfo: DropInfo) -> Bool {
        switch self.現状 {
            case .盤上の駒をドラッグしている:
                guard let 出発地点 = self.ドラッグした盤上の駒の元々の位置 else { return false }
                let 動かした駒 = self.局面.盤駒[出発地点]!
                
                self.局面.盤駒.removeValue(forKey: 出発地点)
                self.局面.手駒[ドロップされた陣営]?.一個増やす(動かした駒.職名)
                
                self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                
            case .持ち駒をドラッグしている:
                guard let 駒 = self.ドラッグした持ち駒 else { return false }
                
                self.局面.手駒[駒.陣営]?.一個減らす(駒.職名)
                self.局面.手駒[ドロップされた陣営]?.一個増やす(駒.職名)
                
                self.駒を移動し終わったらログを更新してフィードバックを発生させる()
                
            case .アプリ外部からドラッグしている:
                let ⓘtemProviders = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
                self.このアイテムを盤面に反映する(ⓘtemProviders)
                
            case .何もドラッグしてない:
                return false
        }
        
        return true
    }
    
    func 駒を移動し終わったらログを更新してフィードバックを発生させる() {
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
        
        if let 🏷 = ⓘtemProvider.suggestedName {
            if 🏷 != "アプリ内でのコマ移動" {
                print("アプリ外部からのアイテムです")
                print("itemProvider.suggestedName: ", 🏷)
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
            if let 局面 = 局面モデル.読み込む() {
                self.局面 = 局面
            } else {
                self.局面 = .初期セット
            }
        }
    }
    
    func ログを更新する() {
        self.局面.保存する()
    }
    
    // ==============================================================================
    // ======================== 以下、テキスト書き出し読み込み機能 ========================
    func 現在の盤面をテキストに変換する() -> String {
        📃テキスト連携機能.テキストに変換する(self.局面)
    }
    
    func このアイテムを盤面に反映する(_ ⓘtemProviders: [NSItemProvider]) {
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


struct データ管理_ver_3_0_2 {
    static var 以前のデータがあるか: Bool {
        UserDefaults.standard.dictionary(forKey: "駒の配置") != nil
        &&
        UserDefaults.standard.dictionary(forKey: "手駒") != nil
    }
    
    static func 以前のデータを削除する() {
        UserDefaults.standard.removeObject(forKey: "駒の配置")
        UserDefaults.standard.removeObject(forKey: "手駒")
    }
    
    static func 以前アプリ起動した際のログを読み込む() -> 局面モデル {
        let 💾 = UserDefaults.standard
        var 駒の配置: [Int: 盤上の駒] = [:]
        var 手駒: [王側か玉側か: 持ち駒] = 空の手駒
        
        if let 駒⃣の配置 = 💾.dictionary(forKey: "駒の配置") as? [String: [String]] {
            if let 手⃣駒 = 💾.dictionary(forKey: "手駒") as? [String: [String: String]] {
                駒⃣の配置.forEach { (位置テキスト: String, 駒テキスト: [String]) in
                    if 駒テキスト.count != 3 { return }
                    if let 陣営 = 王側か玉側か(rawValue: 駒テキスト[0]) {
                        if let 職名 = 駒の種類(rawValue: 駒テキスト[1]) {
                            if let 位置 = Int(位置テキスト) {
                                if let 成り = Bool(駒テキスト[2]) {
                                    駒の配置.updateValue(盤上の駒(陣営, 職名, 成り), forKey: 位置)
                                } else {
                                    駒の配置.updateValue(盤上の駒(陣営, 職名), forKey: 位置)
                                }
                            }
                        }
                    }
                }
                
                王側か玉側か.allCases.forEach { 陣営 in
                    if let 手駒テキスト = 手⃣駒[陣営.rawValue] {
                        手駒テキスト.forEach { (職名テキスト: String, 数テキスト: String) in
                            if let 職名 = 駒の種類(rawValue: 職名テキスト) {
                                if let 数 = Int(数テキスト) {
                                    手駒[陣営]?.配分.updateValue(数, forKey: 職名)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return 局面モデル(盤駒: 駒の配置, 手駒: 手駒)
    }
    
    static func 更新する(駒の配置: [Int: 盤上の駒], 手駒: [王側か玉側か: 持ち駒]) {
        var 駒⃣の配置: [String: [String]] = [:]
        var 手⃣駒: [String: [String: String]] = ["王側": [:], "玉側": [:]]
        
        駒の配置.forEach { (位置: Int, 駒: 盤上の駒) in
            駒⃣の配置.updateValue([駒.陣営.rawValue, 駒.職名.rawValue, 駒.成り.description], forKey: 位置.description)
        }
        
        王側か玉側か.allCases.forEach { 陣営 in
            手駒[陣営]?.配分.forEach { (職名: 駒の種類, 数: Int) in
                手⃣駒[陣営.rawValue]?[職名.rawValue] = 数.description
            }
        }
        
        UserDefaults.standard.set(駒⃣の配置, forKey: "駒の配置")
        UserDefaults.standard.set(手⃣駒, forKey: "手駒")
    }
}




//FIXME: >==== Error: 📦.loadItem ====
//> [Pasteboard] Could not retrieve data representation of type public.utf8-plain-text. Error: Error Domain=NSCocoaErrorDomain Code=4099 "The connection to service created from an endpoint was invalidated from this process." UserInfo={NSDebugDescription=The connection to service created from an endpoint was invalidated from this process.}
//> Error Domain=NSItemProviderErrorDomain Code=-1000 "Data transfer has been cancelled." UserInfo={NSLocalizedDescription=Data transfer has been cancelled.}

//FIXME: >==== Error: 📦.loadItem ====
//> Error Domain=NSItemProviderErrorDomain Code=-1000 "Cannot load representation of type public.text" UserInfo={NSLocalizedDescription=Cannot load representation of type public.text, NSUnderlyingError=0x283f97de0 {Error Domain=PBErrorDomain Code=0 "Cannot load representation of type public.utf8-plain-text" UserInfo={NSLocalizedDescription=Cannot load representation of type public.utf8-plain-text, NSUnderlyingError=0x283f945a0 {Error Domain=NSCocoaErrorDomain Code=4097 "connection to service with pid 68717 created from an endpoint" UserInfo={NSDebugDescription=connection to service with pid 68717 created from an endpoint}}}}}
 
//FIXME: MacOS(Desiened for iPad)で駒移動ができない不具合
//> 2022-07-04 19:41:05.721240+0900 将棋盤[11108:591202] Cannot find representation conforming to type com.apple.UIKit.private.drag-suggested-name
//> 2022-07-04 19:41:05.723046+0900 将棋盤[11108:591259] [DragAndDrop] UIDragging: dataForItemIndex:0 type:com.apple.UIKit.private.drag-suggested-name got error: Error Domain=NSItemProviderErrorDomain Code=-1000 "Cannot load representation of type com.apple.UIKit.private.drag-suggested-name" UserInfo={NSLocalizedDescription=Cannot load representation of type com.apple.UIKit.private.drag-suggested-name}
//> アプリ外部からのアイテムです
