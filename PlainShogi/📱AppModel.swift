
import Combine
import SwiftUI
import UniformTypeIdentifiers

class 📱AppModel: ObservableObject {
    
    @Published var 駒の配置: [Int: 兵] = 初期配置
    
    @Published var 手駒: [王側か玉側か: [駒の種類]] = 初期手駒
    
    @Published var 動き出した駒の位置: Int? = nil
    
    @Published var 持ち上げられた手駒: 兵? = nil
    
    @Published var 現状: 状況 = .駒を持ち上げていない
    
    @AppStorage("English表記") var 🚩English表記: Bool = false
    
    
    func 盤上の駒を持ち上げる(_ ここから: Int) -> NSItemProvider {
        動き出した駒の位置 = ここから
        現状 = .盤上の駒を持ち上げている
        return 外部へテキストを書き出す()
    }
    
    
    func 手駒を持ち上げる(_ これを: 兵) -> NSItemProvider {
        持ち上げられた手駒 = これを
        現状 = .手駒を持ち上げている
        return 外部へテキストを書き出す()
    }
    
    
    func 駒を動かす(_ 行先: Int, _ 📦: [NSItemProvider]) -> Bool {
        guard let 🗂 = 📦.first else { return false }
        
        if let 🏷 = 🗂.suggestedName {
            print("🗂.suggestedName: ", 🏷)
            if 🏷 != "コマ" { 現状 = .駒を持ち上げていない }
        } else {
            print("🗂.suggestedName: nil")
            現状 = .駒を持ち上げていない
        }
        
        switch 現状 {
            case .駒を持ち上げていない:
                🗂.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier, options: nil) { 📁, ⓔrror in
                    if ⓔrror != nil { print("👿 loadItem: ", ⓔrror.debugDescription) }
                    
                    guard let 📋 = 📁 as? Data else { return }
                    
                    if let 📄 = String(data: 📋, encoding: .utf8) {
                        if 📄.first == "☗" {
                            self.外部からテキストを取り込む(📄)
                        }
                    }
                }
            case .盤上の駒を持ち上げている:
                if let 出発地 = 動き出した駒の位置 {
                    if 行先 == 出発地 { return true }
                    
                    if let 先客 = 駒の配置[行先] {
                        if 先客.陣営 == 駒の配置[出発地]?.陣営 { return true }
                        
                        手駒[駒の配置[出発地]!.陣営]!.append(先客.職名.生駒)
                    }
                    
                    駒の配置.updateValue(駒の配置[出発地]!, forKey: 行先)
                    駒の配置.removeValue(forKey: 出発地)
                    
                    動き出した駒の位置 = nil
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
        
        ログ保存()
        
        return true
    }
    
    
    func 駒を裏返す(_ 位置: Int) {
        if let これ = self.駒の配置[位置] {
            if let 裏 = これ.職名.裏側 {
                self.駒の配置[位置] = 兵(これ.陣営, 裏)
            }
        }
        
        振動()
    }
    
    
    func ログ保存() {
        let 🗄 = UserDefaults.standard
        
        var 盤上ログ: [String: [String]] = [:]
        
        駒の配置.forEach { (ｲﾁ: Int, ｺﾏ: 兵) in
            盤上ログ.updateValue([ｺﾏ.陣営.rawValue, ｺﾏ.職名.rawValue], forKey: ｲﾁ.description)
        }
        
        🗄.set(盤上ログ, forKey: "駒の配置")
        
        var 手駒ログ: [String: [String]] = ["王側": [], "玉側": []]
        
        手駒.forEach { (ｼﾞﾝｴｲ: 王側か玉側か, ﾃｺﾞﾏﾀﾁ: [駒の種類]) in
            ﾃｺﾞﾏﾀﾁ.forEach { 手駒ログ[ｼﾞﾝｴｲ.rawValue]?.append($0.rawValue) }
        }
        
        🗄.set(手駒ログ, forKey: "手駒")
    }
    
    
    init() {
        ログ読み込み()
    }
    
    func ログ読み込み() {
        let 🗄 = UserDefaults.standard
        
        var 盤上ログ: [Int: 兵] = [:]
        
        if let 💾 = 🗄.dictionary(forKey: "駒の配置") as? [String: [String]] {
            💾.forEach { (ｲﾁ: String, ｺﾏ: [String]) in
                if let ｼﾞﾝｴｲ = 王側か玉側か.init(rawValue: ｺﾏ[0]) {
                    if let ｼｮｸﾒｲ = 駒の種類.init(rawValue: ｺﾏ[1]) {
                        盤上ログ.updateValue(兵(ｼﾞﾝｴｲ,ｼｮｸﾒｲ), forKey: Int(ｲﾁ)!)
                    }
                }
            }
        }
        
        if 盤上ログ.isEmpty == false {
            駒の配置 = 盤上ログ
        }
        
        
        var 手駒ログ: [王側か玉側か: [駒の種類]] = 初期手駒
        
        if let 💾 = 🗄.dictionary(forKey: "手駒") as? [String:[String]] {
            💾.forEach { (ｼﾞﾝｴｲ: String, ﾃｺﾞﾏﾀﾁ: [String]) in
                ﾃｺﾞﾏﾀﾁ.forEach { ﾃｺﾞﾏ in
                    if let ｼｮｸﾒｲ = 駒の種類.init(rawValue: ﾃｺﾞﾏ) {
                        if let ｼﾞﾝｴｲ = 王側か玉側か.init(rawValue: ｼﾞﾝｴｲ) {
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
        
        self.手駒[.玉側]?.forEach{ ﾃｺﾞﾏ in
            📄 += 🚩English表記 ? ﾃｺﾞﾏ.englishテキスト + "͙" : ﾃｺﾞﾏ.rawValue + "͙"
        }
        
        📄 += "\n－－－－－－－－－\n"
        
        for 行 in 0 ..< 9 {
            for 列 in 0 ..< 9 {
                if let ｺﾏ = self.駒の配置[行*9+列] {
                    📄 += 🚩English表記 ? ｺﾏ.職名.englishテキスト : ｺﾏ.職名.rawValue
                    
                    if ｺﾏ.陣営 == .玉側 {
                        📄 += "͙"
                    }
                } else {
                    📄 += "　"
                }
            }
            📄 += "\n"
        }
        
        📄 += "－－－－－－－－－\n☖"
        
        self.手駒[.王側]?.forEach{ ﾃｺﾞﾏ in
            📄 += 🚩English表記 ? ﾃｺﾞﾏ.englishテキスト : ﾃｺﾞﾏ.rawValue
        }
        
        return 📄
    }
    
    
    func 外部からテキストを取り込む(_ 📦: String) {
        print("📦: ",📦)
        
        var 盤上テキスト: [Int: 兵] = [:]
        
        var 手駒テキスト: [王側か玉側か: [駒の種類]] = 初期手駒
        
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
                駒の種類.allCases.forEach { 種類毎 in
                    if 字 == 種類毎.rawValue || 字 == 種類毎.englishテキスト {
                        手駒テキスト[.王側]?.append(種類毎)
                    }
                    
                    if 字 == 種類毎.rawValue + "͙" || 字 == 種類毎.englishテキスト + "͙" {
                        手駒テキスト[.玉側]?.append(種類毎)
                    }
                }
            }
            
            if 1 < 改行数 && 改行数 < 11 {
                駒の種類.allCases.forEach { 種類毎 in
                    let 座標 = ( 改行数 - 2 ) * 9 + 列
                    
                    if 字 == 種類毎.rawValue || 字 == 種類毎.englishテキスト {
                        盤上テキスト.updateValue(兵(.王側, 種類毎), forKey: 座標)
                    }
                    
                    if 字 == 種類毎.rawValue + "͙" || 字 == 種類毎.englishテキスト + "͙" {
                        盤上テキスト.updateValue(兵(.玉側, 種類毎), forKey: 座標)
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
    
    
    func はじめに戻す() {
        self.駒の配置 = 初期配置
        self.手駒 = 初期手駒
        
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
