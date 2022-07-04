
import Combine
import SwiftUI
import UniformTypeIdentifiers

class 📱AppModel: ObservableObject {
    
    @Published var 駒の配置: [Int: 盤上の駒] = 初期配置
    
    @Published var 手駒: [王側か玉側か: 持ち駒] = 空の手駒
    
    
    @AppStorage("English表記") var 🚩English表記: Bool = false
    
    @AppStorage("移動直後の駒を目立たせる") var 🚩移動直後の駒を目立たせる: Bool = false
    
    
    var ドラッグした盤上の駒の元々の位置: Int? = nil
    
    var ドラッグした持ち駒: (陣営: 王側か玉側か, 職名: 駒の種類)? = nil
    
    var 現状: 状況 = .何もドラッグしてない {
        didSet {
            switch 現状 {
                case .盤上の駒をドラッグしている:
                    ドラッグした持ち駒 = nil
                    移動直後の駒の位置 = nil
                case .持ち駒をドラッグしている:
                    ドラッグした盤上の駒の元々の位置 = nil
                    移動直後の駒の位置 = nil
                case .アプリ外部からドラッグしている, .何もドラッグしてない:
                    ドラッグした盤上の駒の元々の位置 = nil
                    ドラッグした持ち駒 = nil
            }
        }
    }
    
    
    @Published var 移動直後の駒の位置: Int?
    
    
    func この盤上の駒の表記(_ 駒: 盤上の駒) -> String {
        if 駒.成り {
            return 🚩English表記 ? 駒.職名.English成駒表記! : 駒.職名.成駒表記!
        } else {
            if 駒.陣営 == .玉側 && 駒.職名 == .王 {
                return 🚩English表記 ? "K" : "玉"
            } else {
                return 🚩English表記 ? 駒.職名.English生駒表記 : 駒.職名.rawValue
            }
        }
    }
    
    
    func この持ち駒の表記(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> String {
        if 陣営 == .玉側 && 職名 == .王 {
            return 🚩English表記 ? "K" : "玉"
        } else {
            return 🚩English表記 ? 職名.English生駒表記 : 職名.rawValue
        }
    }
    
    
    func この持ち駒の数(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> Int {
        手駒[陣営]?.個数(職名) ?? 0
    }
    
    
    func 盤面を初期化する() {
        駒の配置 = 初期配置
        手駒 = 空の手駒
        
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    
    func この盤上の駒をドラッグし始める(_ 位置: Int) -> NSItemProvider {
        ドラッグした盤上の駒の元々の位置 = 位置
        現状 = .盤上の駒をドラッグしている
        return ドラッグ対象となるアイテムを用意する()
    }
    
    
    func この持ち駒をドラッグし始める(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> NSItemProvider {
        ドラッグした持ち駒 = (陣営, 職名)
        現状 = .持ち駒をドラッグしている
        return ドラッグ対象となるアイテムを用意する()
    }
    
    
    func ドラッグ対象となるアイテムを用意する() -> NSItemProvider {
        let 📃 = 現在の盤面をテキストに変換する()
        let 📦 = NSItemProvider(object: 📃 as NSItemProviderWriting)
        📦.suggestedName = "アプリ内でのコマ移動"
        return 📦
    }
    
    
    // ================================================================================
    // ============================= 以下、ドロップDelegate =============================
    func 盤上のここにドロップする(_ 置いた位置: Int, _ ⓘnfo: DropInfo) -> Bool {
        switch 現状 {
            case .盤上の駒をドラッグしている:
                guard let 出発地点 = ドラッグした盤上の駒の元々の位置 else { return false }
                if 置いた位置 == 出発地点 { return false }
                
                let 動かした駒 = 駒の配置[出発地点]!
                
                if let 先客 = 駒の配置[置いた位置] {
                    if 先客.陣営 == 動かした駒.陣営 { return false }
                    
                    手駒[動かした駒.陣営]?.一個増やす(先客.職名)
                }
                
                駒の配置.removeValue(forKey: 出発地点)
                駒の配置.updateValue(動かした駒, forKey: 置いた位置)
                
                移動直後の駒の位置 = 置いた位置
                駒を移動し終わったらログを更新してフィードバックを発生させる()
                
            case .持ち駒をドラッグしている:
                guard let 駒 = ドラッグした持ち駒 else { return false }
                if 駒の配置[置いた位置] != nil { return false }
                
                駒の配置.updateValue(盤上の駒(駒.陣営, 駒.職名), forKey: 置いた位置)
                
                手駒[駒.陣営]?.一個減らす(駒.職名)
                
                移動直後の駒の位置 = 置いた位置
                駒を移動し終わったらログを更新してフィードバックを発生させる()
                
            case .アプリ外部からドラッグしている:
                let 📦 = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
                このアイテムを盤面に反映する(📦)
                
            case .何もドラッグしてない:
                return false
        }
        
        return true
    }
    
    
    func 盤上のここはドロップ可能か確認する(_ 位置: Int) -> DropProposal? {
        switch 現状 {
            case .盤上の駒をドラッグしている:
                if 位置 == ドラッグした盤上の駒の元々の位置 {
                    return DropProposal(operation: .cancel)
                }
                
                if let 元々の位置 = ドラッグした盤上の駒の元々の位置 {
                    if 駒の配置[位置]?.陣営 == 駒の配置[元々の位置]?.陣営 {
                        return DropProposal(operation: .cancel)
                    }
                }
                
            case .持ち駒をドラッグしている:
                if 駒の配置[位置] != nil {
                    return .init(operation: .cancel)
                }
                
            case .アプリ外部からドラッグしている, .何もドラッグしてない:
                return nil
        }
        
        return nil
    }
    
    func 盤外のここはドロップ可能か確認する(_ ドロップしようとしている陣営: 王側か玉側か) -> DropProposal? {
        if 現状 == .持ち駒をドラッグしている {
            if let 駒 = ドラッグした持ち駒 {
                if ドロップしようとしている陣営 == 駒.陣営 {
                    return DropProposal(operation: .cancel)
                }
            }
        }
        
        return nil
    }
    
        
    func 有効なドロップかチェックする(_ ⓘnfo: DropInfo) -> Bool {
        let 📦ItemProvider = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
        guard let 📦 = 📦ItemProvider.first else { return false }
        
        if let 🏷 = 📦.suggestedName {
            if 🏷 != "アプリ内でのコマ移動" {
                print("アプリ外部からのアイテムです")
                print("📦.suggestedName: ", 🏷)
                現状 = .アプリ外部からドラッグしている
            }
        } else {
            print("アプリ外部からのアイテムです")
            現状 = .アプリ外部からドラッグしている
        }
        
        return true
    }
    
    
    func 盤外にドロップする(_ ドロップされた陣営: 王側か玉側か, _ ⓘnfo: DropInfo) -> Bool {
        switch 現状 {
            case .盤上の駒をドラッグしている:
                guard let 出発地点 = ドラッグした盤上の駒の元々の位置 else { return false }
                let 動かした駒 = 駒の配置[出発地点]!
                
                駒の配置.removeValue(forKey: 出発地点)
                手駒[ドロップされた陣営]?.一個増やす(動かした駒.職名)
                
                駒を移動し終わったらログを更新してフィードバックを発生させる()
                
            case .持ち駒をドラッグしている:
                guard let 駒 = ドラッグした持ち駒 else { return false }
                
                手駒[駒.陣営]?.一個減らす(駒.職名)
                手駒[ドロップされた陣営]?.一個増やす(駒.職名)
                
                駒を移動し終わったらログを更新してフィードバックを発生させる()
                
            case .アプリ外部からドラッグしている:
                let 📦 = ⓘnfo.itemProviders(for: [UTType.utf8PlainText])
                このアイテムを盤面に反映する(📦)
                
            case .何もドラッグしてない:
                return false
        }
        
        return true
    }
    
    
    func 駒を移動し終わったらログを更新してフィードバックを発生させる() {
        現状 = .何もドラッグしてない
        ログを更新する()
        振動フィードバック()
    }
    
    
    // ==============================================================================
    // ============================= 以下、ログの更新や保存 =============================
    init() {
        以前アプリ起動した際のログを読み込む()
    }
    
    func 以前アプリ起動した際のログを読み込む() {
        let 🗄 = UserDefaults.standard
        
        if let 駒⃣の配置 = 🗄.dictionary(forKey: "駒の配置") as? [String: [String]] {
            if let 手⃣駒 = 🗄.dictionary(forKey: "手駒") as? [String: [String: String]] {
                駒の配置 = [:]
                手駒 = 空の手駒
                
                駒⃣の配置.forEach { (位置テキスト: String, 駒テキスト: [String]) in
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
    }
    
    
    func ログを更新する() {
        let 🗄 = UserDefaults.standard
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
        
        🗄.set(駒⃣の配置, forKey: "駒の配置")
        🗄.set(手⃣駒, forKey: "手駒")
    }
    
    
    // ==============================================================================
    // ======================== 以下、テキスト書き出し読み込み機能 ========================
    func 現在の盤面をテキストに変換する() -> String {
        var 📃 = "☗"

        駒の種類.allCases.forEach { 職名 in
            if let 数 = 手駒[.玉側]?.個数(職名) {
                if 数 >= 1 {
                    📃 += 🚩English表記 ? 駒をEnglishプレーンテキストに変換(職名) : 職名.rawValue
                    📃 += "͙"
                }
                
                if 数 >= 2 {
                    📃 += 数.description
                }
            }
        }

        📃 += "\n－－－－－－－－－\n"

        for 行 in 0 ..< 9 {
            for 列 in 0 ..< 9 {
                if let 駒 = 駒の配置[行*9+列] {
                    if 🚩English表記 {
                        📃 += 駒をEnglishプレーンテキストに変換(駒.職名, 駒.成り)
                    } else {
                        📃 += 駒.成り ? 駒.職名.成駒表記! : 駒.職名.rawValue
                    }

                    if 駒.陣営 == .玉側 {
                        📃 += "͙"
                    }
                } else {
                    📃 += "　"
                }
            }
            📃 += "\n"
        }

        📃 += "－－－－－－－－－\n☖"

        駒の種類.allCases.forEach { 職名 in
            if let 数 = 手駒[.王側]?.個数(職名) {
                if 数 >= 1 {
                    📃 += 🚩English表記 ? 駒をEnglishプレーンテキストに変換(職名) : 職名.rawValue
                }
                
                if 数 >= 2 {
                    📃 += 数.description
                }
            }
        }

        return 📃
    }
    
    
    func このアイテムを盤面に反映する(_ 📦ItemProvider: [NSItemProvider]) {
        Task { @MainActor in
            do {
                guard let 📦 = 📦ItemProvider.first else { return }
                let 🅂ecureCoding = try await 📦.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier)
                guard let 💾 = 🅂ecureCoding as? Data else { return }
                guard let 📃 = String(data: 💾, encoding: .utf8) else { return }
                if 📃.first != "☗" { return }
                
                var 駒⃣の配置: [Int: 盤上の駒] = [:]
                var 手⃣駒: [王側か玉側か: 持ち駒] = 空の手駒
                
                var 改行数: Int = 0
                var 列: Int = 0
                var 読み込み中の持ち駒の種類: 駒の種類 = .歩
                
                for 字区切り in 📃 {
                    if 字区切り == "\n" {
                        改行数 += 1
                        列 = 0
                        continue
                    }
                    
                    let 駒テキスト = 字区切り.description
                    
                    switch 改行数 {
                        case 0:
                            if let 数 = Int(駒テキスト) {
                                手⃣駒[.玉側]?.配分[読み込み中の持ち駒の種類] = 数
                            } else {
                                if let 駒 = プレーンテキストを駒に変換(駒テキスト) {
                                    手⃣駒[駒.陣営]?.配分[駒.職名] = 1
                                    
                                    読み込み中の持ち駒の種類 = 駒.職名
                                }
                            }
                        case 1...11:
                            let 位置 = ( 改行数 - 2 ) * 9 + 列
                            
                            if let 駒 = プレーンテキストを駒に変換(駒テキスト) {
                                駒⃣の配置.updateValue(盤上の駒(駒.陣営, 駒.職名, 駒.成り), forKey: 位置)
                            }
                        case 12:
                            if let 数 = Int(駒テキスト) {
                                手⃣駒[.王側]?.配分[読み込み中の持ち駒の種類] = 数
                            } else {
                                if let 駒 = プレーンテキストを駒に変換(駒テキスト) {
                                    手⃣駒[駒.陣営]?.配分[駒.職名] = 1
                                    
                                    読み込み中の持ち駒の種類 = 駒.職名
                                }
                            }
                        default: break
                    }
                    
                    列 += 1
                }
                
                駒の配置 = 駒⃣の配置
                手駒 = 手⃣駒
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                現状 = .何もドラッグしてない
            } catch {
                print("======== ⚠️ Error: 📦.loadItem ========")
                print(error)
            }
        }
    }
}


func 駒をEnglishプレーンテキストに変換(_ 職名: 駒の種類, _ 成り: Bool = false) -> String {
    switch 職名 {
        case .歩: return 成り ? "ｐ" : "Ｐ"
        case .角: return 成り ? "ｂ" : "Ｂ"
        case .飛: return 成り ? "ｒ" : "Ｒ"
        case .香: return 成り ? "ｌ" : "Ｌ"
        case .桂: return 成り ? "ｎ" : "Ｎ"
        case .銀: return 成り ? "ｓ" : "Ｓ"
        case .金: return "Ｇ"
        case .王: return "Ｋ"
    }
}


func プレーンテキストを駒に変換(_ テキスト: String) -> (陣営: 王側か玉側か, 職名: 駒の種類, 成り: Bool)? {
    var 陣営: 王側か玉側か = .王側
    var 職名: 駒の種類 = .歩
    var 成り = false
    
    if テキスト.unicodeScalars.contains("͙") {
        陣営 = .玉側
    }
    
    if let 職名テキスト = テキスト.unicodeScalars.first?.description {
        switch 職名テキスト {
            case "歩","Ｐ": 職名 = .歩
            case "角","Ｂ": 職名 = .角
            case "飛","Ｒ": 職名 = .飛
            case "香","Ｌ": 職名 = .香
            case "桂","Ｎ": 職名 = .桂
            case "銀","Ｓ": 職名 = .銀
            case "金","Ｇ": 職名 = .金
            case "王","玉","Ｋ": 職名 = .王
            case "と","ｐ": (職名, 成り) = (.歩, true)
            case "馬","ｂ": (職名, 成り) = (.角, true)
            case "龍","ｒ": (職名, 成り) = (.飛, true)
            case "杏","ｌ": (職名, 成り) = (.香, true)
            case "圭","ｎ": (職名, 成り) = (.桂, true)
            case "全","ｓ": (職名, 成り) = (.銀, true)
            default: return nil
        }
    }

    return (陣営, 職名, 成り)
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
