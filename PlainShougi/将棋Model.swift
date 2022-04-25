
import Combine
import SwiftUI
import UniformTypeIdentifiers


let 初期配置: [Int: 兵] =
[0:兵(.玉,.香), 1:兵(.玉,.桂), 2:兵(.玉,.銀), 3:兵(.玉,.金), 4:兵(.玉,.玉), 5:兵(.玉,.金), 6:兵(.玉,.銀), 7:兵(.玉,.桂), 8:兵(.玉,.香),
 10:兵(.玉,.飛),16:兵(.玉,.角),
 18:兵(.玉,.歩),19:兵(.玉,.歩),20:兵(.玉,.歩),21:兵(.玉,.歩),22:兵(.玉,.歩),23:兵(.玉,.歩),24:兵(.玉,.歩),25:兵(.玉,.歩),26:兵(.玉,.歩),
 54:兵(.王,.歩),55:兵(.王,.歩),56:兵(.王,.歩),57:兵(.王,.歩),58:兵(.王,.歩),59:兵(.王,.歩),60:兵(.王,.歩),61:兵(.王,.歩),62:兵(.王,.歩),
 64:兵(.王,.角),70:兵(.王,.飛),
 72:兵(.王,.香),73:兵(.王,.桂),74:兵(.王,.銀),75:兵(.王,.金),76:兵(.王,.王),77:兵(.王,.金),78:兵(.王,.銀),79:兵(.王,.桂),80:兵(.王,.香)]


enum 王か玉か: String {
    case 王
    case 玉
}


enum 種類: String, CaseIterable, Identifiable {
    
    case 歩
    case 角
    case 飛
    case 香
    case 桂
    case 銀
    case 金
    case 王
    case 玉
    
    case と
    case 馬
    case 龍
    case 杏 //成香
    case 圭 //成桂
    case 全 //成銀
    
    var id: String { self.rawValue }
    
    var 裏側: Self? {
        switch self {
        case .歩: return .と
        case .と: return .歩
        case .角: return .馬
        case .馬: return .角
        case .飛: return .龍
        case .龍: return .飛
        case .香: return .杏
        case .杏: return .香
        case .桂: return .圭
        case .圭: return .桂
        case .銀: return .全
        case .全: return .銀
        default: return nil
        }
    }
    
    var 生駒: Self {
        switch self {
        case .と: return .歩
        case .馬: return .角
        case .龍: return .飛
        case .杏: return .香
        case .圭: return .桂
        case .全: return .銀
        default: return self
        }
    }
    
    var english: String {
        switch self {
        case .歩: return "P"
        case .と: return "+P"
        case .角: return "B"
        case .馬: return "+B"
        case .飛: return "R"
        case .龍: return "+R"
        case .香: return "L"
        case .杏: return "+L"
        case .桂: return "N"
        case .圭: return "+N"
        case .銀: return "S"
        case .全: return "+S"
        case .金: return "G"
        case .王: return "K"
        case .玉: return "K"
        }
    }
}


struct 兵 {
    let 陣営: 王か玉か
    let 職名: 種類
    
    init(_ ｼﾞﾝｴｲ: 王か玉か, _ ｼｮｸﾒｲ: 種類) {
        陣営 = ｼﾞﾝｴｲ
        職名 = ｼｮｸﾒｲ
    }
}


enum 段階 {
    case アクティブ直後
    case コマ移動
    case コマ召喚
}


class 将棋Model: ObservableObject {
    
    @Published var 盤上: [Int: 兵] = 初期配置
    
    @Published var 手駒: [王か玉か: [種類]] = [.玉: [], .王: []]
    
    @Published var 盤上のここから: Int? = nil
    
    @Published var 盤外のこれを: 兵? = nil
    
    @Published var 今: 段階 = .アクティブ直後
    
    
    func 持ち上げる(_ ここから: Int) -> NSItemProvider {
        盤上のここから = ここから
        今 = .コマ移動
        return 外部へテキストを書き出す()
    }
    
    
    func 持ち上げる(_ これを: 兵) -> NSItemProvider {
        盤外のこれを = これを
        今 = .コマ召喚
        return 外部へテキストを書き出す()
    }
    
    
    func 移動(_ 行先: Int, _ 📦: [NSItemProvider]) -> Bool {
        guard let 🗂 = 📦.first else { return false }
        
        switch 今 {
        case .アクティブ直後:
            🗂.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier, options: nil) { 📁, ⓔrror in
                
                if ⓔrror != nil { print("👿: ", ⓔrror.debugDescription) }
                
                guard let 📋 = 📁 as? Data else { return }
                
                if let 📄 = String(data: 📋, encoding: .utf8) {
                    if 📄.first == "☗" {
                        print("おそらく将棋盤のデータです")
                        
                        DispatchQueue.main.async {
                            self.外部からテキストを取り込む(📄)
                        }
                    }
                }
            }
            //provider.loadObject(ofClass: String.self) { NSItemProviderReadingA, ErrorA in
            // print("NSItemProviderReadingA?: ", NSItemProviderReadingA?.debugDescription)
            //}
        case .コマ移動:
            let 出発地 = 盤上のここから!
                
            if 行先 == 出発地 { return true }
            
            if let 先客 = 盤上[行先] {
                if 先客.陣営 == 盤上[出発地]?.陣営 { return true }
                
                手駒[盤上[出発地]!.陣営]!.append(先客.職名.生駒)
            }
            
            盤上.updateValue(盤上[出発地]!, forKey: 行先)
            盤上.removeValue(forKey: 出発地)
            
            盤上のここから = nil
        case .コマ召喚:
            let これ = 盤外のこれを!
                
            if 盤上[行先] != nil { return true }
            
            盤上.updateValue(これ, forKey: 行先)
            
            let ひとつ = 手駒[これ.陣営]!.firstIndex(of:これ.職名)!
            手駒[これ.陣営]!.remove(at: ひとつ)
            
            盤外のこれを = nil
        }
        
        ログ保存()
        
        return true
    }
    
    func 外部からテキストを取り込む(_ 📦: String) {
        print(📦)
        
        var 盤上テキスト: [Int: 兵] = [:]
        
        var 手駒テキスト: [王か玉か: [種類]] = [.玉: [], .王: []]
        
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
                種類.allCases.forEach { ｼｭﾙｲ in
                    if 字 == ｼｭﾙｲ.rawValue || 字 == ｼｭﾙｲ.english {
                        手駒テキスト[.王]?.append(ｼｭﾙｲ)
                    }
                    
                    if 字 == ｼｭﾙｲ.rawValue + "͙" || 字 == ｼｭﾙｲ.english + "͙" {
                        手駒テキスト[.玉]?.append(ｼｭﾙｲ)
                    }
                }
            }
            
            if 1 < 改行数 && 改行数 < 11 {
                種類.allCases.forEach { ｼｭﾙｲ in
                    let 座標 = ( 改行数 - 2 ) * 9 + 列
                    
                    if 字 == ｼｭﾙｲ.rawValue || 字 == ｼｭﾙｲ.english {
                        盤上テキスト.updateValue(兵(.王, ｼｭﾙｲ), forKey: 座標)
                    }

                    if 字 == ｼｭﾙｲ.rawValue + "͙" || 字 == ｼｭﾙｲ.english + "͙" {
                        盤上テキスト.updateValue(兵(.玉, ｼｭﾙｲ), forKey: 座標)
                    }
                }
            }
            
            列 += 1
        }
        
        DispatchQueue.main.async {
            self.盤上 = 盤上テキスト
            self.手駒 = 手駒テキスト
        }
    }
    
    
    func 裏返す(_ 位置: Int) {
        if let これ = self.盤上[位置] {
            if let 裏 = これ.職名.裏側 {
                self.盤上[位置] = 兵(これ.陣営, 裏)
            }
        }
    }
    
    
    func ログ保存() {
        let 🗄 = UserDefaults.standard
        
        var 盤上ログ: [String: [String]] = [:]
        
        盤上.forEach { (ｲﾁ: Int, ｺﾏ: 兵) in
            盤上ログ.updateValue([ｺﾏ.陣営.rawValue, ｺﾏ.職名.rawValue], forKey: ｲﾁ.description)
        }
        
        🗄.set(盤上ログ, forKey: "盤上")
        
        var 手駒ログ: [String: [String]] = ["王": [], "玉": []]
        
        手駒.forEach { (ｼﾞﾝｴｲ: 王か玉か, ﾃｺﾞﾏﾀﾁ: [種類]) in
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
        
        if let 💾 = 🗄.dictionary(forKey: "盤上") as? [String: [String]] {
            💾.forEach { (ｲﾁ: String, ｺﾏ: [String]) in
                if let ｼﾞﾝｴｲ = 王か玉か.init(rawValue: ｺﾏ[0]) {
                    if let ｼｮｸﾒｲ = 種類.init(rawValue: ｺﾏ[1]) {
                        盤上ログ.updateValue(兵(ｼﾞﾝｴｲ,ｼｮｸﾒｲ), forKey: Int(ｲﾁ)!)
                    }
                }
            }
        }
        
        if 盤上ログ.isEmpty == false {
            盤上 = 盤上ログ
        }
        
        
        var 手駒ログ: [王か玉か: [種類]] = [.王:[], .玉:[]]
        
        if let 💾 = 🗄.dictionary(forKey: "手駒") as? [String:[String]] {
            💾.forEach { (ｼﾞﾝｴｲ: String, ﾃｺﾞﾏﾀﾁ: [String]) in
                ﾃｺﾞﾏﾀﾁ.forEach { ﾃｺﾞﾏ in
                    if let ｼｮｸﾒｲ = 種類.init(rawValue: ﾃｺﾞﾏ) {
                        if let ｼﾞﾝｴｲ = 王か玉か.init(rawValue: ｼﾞﾝｴｲ) {
                            手駒ログ[ｼﾞﾝｴｲ]?.append(ｼｮｸﾒｲ)
                        }
                    }
                }
            }
        }
        
        手駒 = 手駒ログ
    }
    
    
    func 外部へテキストを書き出す() -> NSItemProvider {
        
        let English表記 = UserDefaults.standard.bool(forKey: "English表記")
        
        var 📄 = "\n☗"
        
        self.手駒[.玉]?.forEach{ ﾃｺﾞﾏ in
            if English表記 {
                📄 += ﾃｺﾞﾏ.english + "͙"
            } else {
                📄 += ﾃｺﾞﾏ.rawValue + "͙"
            }
        }
        
        📄 += "\n－－－－－－－－－\n"
        
        for 行 in 0 ..< 9 {
            for 列 in 0 ..< 9 {
                if let ｺﾏ = self.盤上[行*9+列] {
                    if ｺﾏ.陣営 == .玉 {
                        if English表記 {
                            📄 += ｺﾏ.職名.english.description + "͙"
                        } else {
                            📄 += ｺﾏ.職名.rawValue + "͙"
                        }
                    } else {
                        if English表記 {
                            📄 += ｺﾏ.職名.english.description
                        } else {
                            📄 += ｺﾏ.職名.rawValue
                        }
                    }
                } else {
                    📄 += "　"
                }
            }
            📄 += "\n"
        }

        📄 += "－－－－－－－－－\n☖"
        
        self.手駒[.王]?.forEach{ ﾃｺﾞﾏ in
            if English表記 {
                📄 += ﾃｺﾞﾏ.english
            } else {
                📄 += ﾃｺﾞﾏ.rawValue
            }
        }
        
        return NSItemProvider(object: 📄 as NSItemProviderWriting)
    }
    
    
    func はじめに戻す() {
        self.盤上 = 初期配置
        self.手駒 = [.玉: [], .王: []]
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
