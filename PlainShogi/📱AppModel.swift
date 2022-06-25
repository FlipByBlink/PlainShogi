
import Combine
import SwiftUI
import UniformTypeIdentifiers

class 📱AppModel: ObservableObject {
    
    @Published var 駒の配置: [Int: 将棋駒] = 初期配置
    
    @Published var 手駒: [王側か玉側か: [駒の種類]] = 初期手駒
    
    @Published var 持ち上げられた駒の元々の位置: Int? = nil
    
    @Published var 持ち上げられた手駒: 将棋駒? = nil
    
    @Published var 現状: 状況 = .駒を持ち上げていない
    
    @AppStorage("English表記") var 🚩English表記: Bool = false
    
    
    func 盤上の駒を持ち上げる(_ ここから: Int) -> NSItemProvider {
        持ち上げられた駒の元々の位置 = ここから
        現状 = .盤上の駒を持ち上げている
        return 外部へテキストを書き出す()
    }
    
    
    func 手駒を持ち上げる(_ これを: 将棋駒) -> NSItemProvider {
        持ち上げられた手駒 = これを
        現状 = .手駒を持ち上げている
        return 外部へテキストを書き出す()
    }
    
    
    func 持ち上げていた駒をここに置く(_ 行先: Int, _ 📦: [NSItemProvider]) -> Bool {
        guard let 🗂 = 📦.first else { return false }
        
        if let 🏷 = 🗂.suggestedName {
            print("🗂.suggestedName: ", 🏷) //TODO: 再検討
            if 🏷 != "コマ" { 現状 = .駒を持ち上げていない }
        } else {
            print("🗂.suggestedName: nil") //TODO: 再検討
            現状 = .駒を持ち上げていない
        }
        
        switch 現状 {
            case .駒を持ち上げていない:
                🗂.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier, options: nil) { 📁, ⓔrror in //TODO: async/await実装
                    if ⓔrror != nil { print("👿 loadItem: ", ⓔrror.debugDescription) }
                    
                    guard let 📋 = 📁 as? Data else { return }
                    
                    if let 📄 = String(data: 📋, encoding: .utf8) {
                        if 📄.first == "☗" {
                            self.外部からテキストを取り込む(📄)
                        }
                    }
                }
            case .盤上の駒を持ち上げている:
                if let 出発地点 = 持ち上げられた駒の元々の位置 {
                    if 行先 == 出発地点 { return true }
                    
                    if let 先客 = 駒の配置[行先] {
                        if 先客.陣営 == 駒の配置[出発地点]?.陣営 { return true }
                        
                        手駒[駒の配置[出発地点]!.陣営]!.append(先客.職名.生駒)
                    }
                    
                    駒の配置.updateValue(駒の配置[出発地点]!, forKey: 行先)
                    駒の配置.removeValue(forKey: 出発地点)
                    
                    持ち上げられた駒の元々の位置 = nil
                } else { print("🐛") }
            case .手駒を持ち上げている:
                if let これ = 持ち上げられた手駒 {
                    if 駒の配置[行先] != nil { return true }
                    
                    駒の配置.updateValue(これ, forKey: 行先)
                    
                    let ひとつ = 手駒[これ.陣営]!.firstIndex(of:これ.職名)!
                    手駒[これ.陣営]!.remove(at: ひとつ)
                    
                    持ち上げられた手駒 = nil
                } else { print("🐛") }
        }
        
        ログを更新する()
        
        return true
    }
    
    
    func 駒を裏返す(_ 位置: Int) {
        if let これ = self.駒の配置[位置] {
            if let 裏 = これ.職名.裏側 {
                self.駒の配置[位置] = 将棋駒(これ.陣営, 裏)
            }
        }
        
        振動フィードバック()
    }
    
    
    func ログを更新する() {
        let 🗄 = UserDefaults.standard
        
        var 盤上ログ: [String: [String]] = [:]
        
        駒の配置.forEach { (位置: Int, 駒: 将棋駒) in
            盤上ログ.updateValue([駒.陣営.rawValue, 駒.職名.rawValue], forKey: 位置.description)
        }
        
        🗄.set(盤上ログ, forKey: "駒の配置")
        
        var 手駒ログ: [String: [String]] = ["王側": [], "玉側": []]
        
        手駒.forEach { (陣営: 王側か玉側か, ﾃｺﾞﾏﾀﾁ: [駒の種類]) in //FIXME: 命名
            ﾃｺﾞﾏﾀﾁ.forEach { 手駒ログ[陣営.rawValue]?.append($0.rawValue) }
        }
        
        🗄.set(手駒ログ, forKey: "手駒")
    }
    
    
    init() {
        ログを読み込む()
    }
    
    func ログを読み込む() {
        let 🗄 = UserDefaults.standard
        
        var 盤上ログ: [Int: 将棋駒] = [:]
        
        if let 💾 = 🗄.dictionary(forKey: "駒の配置") as? [String: [String]] {
            💾.forEach { (位置: String, 駒: [String]) in
                if let 陣営 = 王側か玉側か(rawValue: 駒[0]) {
                    if let 職名 = 駒の種類(rawValue: 駒[1]) {
                        盤上ログ.updateValue(将棋駒(陣営,職名), forKey: Int(位置)!)
                    }
                }
            }
        }
        
        if 盤上ログ.isEmpty == false {
            駒の配置 = 盤上ログ
        }
        
        
        var 手駒ログ = 初期手駒
        
        if let 💾 = 🗄.dictionary(forKey: "手駒") as? [String:[String]] {
            💾.forEach { (ｼﾞﾝｴｲ: String, ﾃｺﾞﾏﾀﾁ: [String]) in //FIXME: 命名
                ﾃｺﾞﾏﾀﾁ.forEach { ﾃｺﾞﾏ in
                    if let ｼｮｸﾒｲ = 駒の種類(rawValue: ﾃｺﾞﾏ) {
                        if let ｼﾞﾝｴｲ = 王側か玉側か(rawValue: ｼﾞﾝｴｲ) {
                            手駒ログ[ｼﾞﾝｴｲ]?.append(ｼｮｸﾒｲ)
                        }
                    }
                }
            }
        }
        
        手駒 = 手駒ログ
    }
    
    
    func 外部へテキストを書き出す() -> NSItemProvider {
        var 📄 = "\n"
        📄 += テキストに変換する()
        
        let 📦 = NSItemProvider(object: 📄 as NSItemProviderWriting)
        📦.suggestedName = "コマ"
        return 📦
    }
    
    
    func テキストに変換する() -> String {
        var 📄 = "☗"
        
        self.手駒[.玉側]?.forEach{ 駒 in
            📄 += 🚩English表記 ? 駒.Englishプレーンテキスト + "͙" : 駒.rawValue + "͙"
        }
        
        📄 += "\n－－－－－－－－－\n"
        
        for 行 in 0 ..< 9 {
            for 列 in 0 ..< 9 {
                if let 駒 = self.駒の配置[行*9+列] {
                    📄 += 🚩English表記 ? 駒.職名.Englishプレーンテキスト : 駒.職名.rawValue
                    
                    if 駒.陣営 == .玉側 {
                        📄 += "͙"
                    }
                } else {
                    📄 += "　"
                }
            }
            📄 += "\n"
        }
        
        📄 += "－－－－－－－－－\n☖"
        
        self.手駒[.王側]?.forEach{ 駒 in
            📄 += 🚩English表記 ? 駒.Englishプレーンテキスト : 駒.rawValue
        }
        
        return 📄
    }
    
    
    func 外部からテキストを取り込む(_ 📦: String) {
        print("📦: ",📦)
        
        var 盤上テキスト: [Int: 将棋駒] = [:]
        
        var 手駒テキスト = 初期手駒
        
        var 改行数: Int = 0
        
        var 列: Int = 0
        
        for 文字1つ in 📦 {
            if 文字1つ == "\n" {
                改行数 += 1
                列 = 0
                continue
            }
            
            let 字 = 文字1つ.description
            
            if 改行数 == 0 || 改行数 == 12 {
                駒の種類.allCases.forEach { 職名 in
                    if 字 == 職名.rawValue || 字 == 職名.Englishプレーンテキスト {
                        手駒テキスト[.王側]?.append(職名)
                    }
                    
                    if 字 == 職名.rawValue + "͙" || 字 == 職名.Englishプレーンテキスト + "͙" {
                        手駒テキスト[.玉側]?.append(職名)
                    }
                }
            }
            
            if 1 < 改行数 && 改行数 < 11 {
                駒の種類.allCases.forEach { 職名 in
                    let 座標 = ( 改行数 - 2 ) * 9 + 列
                    
                    if 字 == 職名.rawValue || 字 == 職名.Englishプレーンテキスト {
                        盤上テキスト.updateValue(将棋駒(.王側, 職名), forKey: 座標)
                    }
                    
                    if 字 == 職名.rawValue + "͙" || 字 == 職名.Englishプレーンテキスト + "͙" {
                        盤上テキスト.updateValue(将棋駒(.玉側, 職名), forKey: 座標)
                    }
                }
            }
            
            列 += 1
        }
        
        DispatchQueue.main.async {
            self.駒の配置 = 盤上テキスト
            self.手駒 = 手駒テキスト
        }
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    
    func 盤面を初期化する() {
        self.駒の配置 = 初期配置
        self.手駒 = 初期手駒
        
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
