
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


let 初期配置String: [String] =
["香͙","桂͙","銀͙","金͙","玉͙","金͙","銀͙","桂͙","香͙",
 "　","飛͙","　","　","　","　","　","角͙","　",
 "歩͙","歩͙","歩͙","歩͙","歩͙","歩͙","歩͙","歩͙","歩͙",
 "　","　","　","　","　","　","　","　","　",
 
 "　","　","　","　","　","　","　","　","　",
 
 "　","　","　","　","　","　","　","　","　",
 "歩","歩","歩","歩","歩","歩","歩","歩","歩",
 "　","角","　","　","　","　","　","飛","　",
 "香","桂","銀","金","王","金","銀","桂","香"]


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


class 配置Model: ObservableObject {
    
    @Published var 盤上: [Int: 兵] = 初期配置
    
    @Published var 手駒: [王か玉か: [種類]] = [.玉: [], .王: []]
    
    @Published var 盤上のここから: Int? = nil
    
    @Published var 盤外のこれを: 兵? = nil
    
    
    func 持ち上げる(_ ここ: Int) -> NSItemProvider {
        盤上のここから = ここ
        盤外のこれを = nil
        return 書き出す()
    }
    
    
    func 持ち上げる(_ これ: 兵) -> NSItemProvider {
        盤外のこれを = これ
        盤上のここから = nil
        return 書き出す()
    }
    
    
    func 移動(ここへ: Int, _ 📦: [NSItemProvider]) -> Bool {
        guard let 🗂 = 📦.first else { return false }
        🗂.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier, options: nil) { NSSecureCodingA, ⓔrror in
            
            if ⓔrror != nil { print("👿: ", ⓔrror.debugDescription) }
            
            guard let 📋 = NSSecureCodingA as? Data else { return }
            if let 📄 = String(data: 📋, encoding: .utf8) {
                if 📄.first == "☗" {
                    print("将棋盤のデータです")
                    self.外部から取り込む(📄)
                } else if 📄.first == "\n" {
                    print("おそらくゲーム内でのコマの移動です")
                } else {
                    print("🐛")
                }
            }
        }
        
//        provider.loadObject(ofClass: String.self) { NSItemProviderReadingA, ErrorA in
//            print("NSItemProviderReadingA?: ", NSItemProviderReadingA?.debugDescription)
//        }
        
        if let 出発地 = 盤上のここから {
            
            if ここへ == 出発地 { return true }
            
            if let 先客 = 盤上[ここへ] {
                if 先客.陣営 == 盤上[出発地]?.陣営 { return true }
                
                手駒[盤上[出発地]!.陣営]!.append(先客.職名.生駒)
            }
            
            盤上.updateValue(盤上[出発地]!, forKey: ここへ)
            盤上.removeValue(forKey: 出発地)
            
            盤上のここから = nil
        }
        
        if let これ = 盤外のこれを {
            
            if 盤上[ここへ] != nil { return true }
            
            盤上.updateValue(これ, forKey: ここへ)
            let ひとつ = 手駒[これ.陣営]!.firstIndex(of:これ.職名)!
            手駒[これ.陣営]!.remove(at: ひとつ)
            
            盤外のこれを = nil
        }
        
        データ保存()
        
        return true
    }
    
    func 外部から取り込む(_ 📦: String) {
        print(📦)
        
        var 盤上のコマ: [Int: 兵] = [:]
        
        var ﾃｺﾞﾏ: [王か玉か: [種類]] = [.玉: [], .王: []]
        
        var 改行数: Int = 0
        
        var 位置: Int = 0
        
        for 文字 in 📦 {
            print("a.d:" + 文字.description + "; 位置:" + 位置.description + ";")
            if 文字 == "\n" {
                print("文字 == \\n")
                改行数 += 1
                continue
            }
            
            if 改行数 == 0 || 改行数 == 12 {
                種類.allCases.forEach { ｼｮｸﾒｲ in
                    print("ｼｮｸﾒｲ:",ｼｮｸﾒｲ)
                    
                    if 文字.description == ｼｮｸﾒｲ.rawValue {
                        ﾃｺﾞﾏ[.王]?.append(ｼｮｸﾒｲ)
                    }
                    
                    if 文字.description == ｼｮｸﾒｲ.rawValue + "͙" {
                        ﾃｺﾞﾏ[.玉]?.append(ｼｮｸﾒｲ)
                    }
                }
            }
            
            if 1 < 改行数 && 改行数 < 11 {
                種類.allCases.forEach { ｼｮｸﾒｲ in
                    print("ｼｮｸﾒｲ:",ｼｮｸﾒｲ)
                    
                    if 文字.description == ｼｮｸﾒｲ.rawValue {
                        盤上のコマ.updateValue(兵(.王, ｼｮｸﾒｲ), forKey: 位置)
                    }

                    if 文字.description == ｼｮｸﾒｲ.rawValue + "͙" {
                        盤上のコマ.updateValue(兵(.玉, ｼｮｸﾒｲ), forKey: 位置)
                    }
                }
                位置 += 1
            }
        }
        
        print(盤上のコマ.debugDescription)
        
        DispatchQueue.main.async {
            self.盤上 = 盤上のコマ //fix later
            self.手駒 = ﾃｺﾞﾏ
        }
    }
    
    
    func 裏返す(_ 位置: Int) {
        if let これ = self.盤上[位置] {
            if let 裏 = これ.職名.裏側 {
                self.盤上[位置] = 兵(これ.陣営, 裏)
            }
        }
    }
    
    
    func データ保存() {
        let 🗄 = UserDefaults.standard
        
        var 盤上メモ: [String: [String]] = [:]
        
        盤上.forEach { (key: Int, value: 兵) in
            盤上メモ.updateValue([value.陣営.rawValue, value.職名.rawValue], forKey: key.description)
        }
        
        🗄.set(盤上メモ, forKey: "盤上")
        
        var 手駒メモ: [String: [String]] = ["王": [], "玉": []]
        
        手駒.forEach { (key: 王か玉か, value: [種類]) in
            value.forEach { 職名 in
                手駒メモ[key.rawValue]?.append(職名.rawValue)
            }
        }
        
        🗄.set(手駒メモ, forKey: "手駒")
    }
    
    
    init() {
        データ読み込み()
    }
    
    func データ読み込み() {
        let 🗄 = UserDefaults.standard
        
        var 盤上メモ: [Int: 兵] = [:]
        
        if let 💾 = 🗄.dictionary(forKey: "盤上") as? [String:[String]] {
            💾.forEach { (key: String, value: [String]) in
                if let 位置 = Int(key) {
                    if let 陣営 = 王か玉か.init(rawValue: value[0]) {
                        if let 職名 = 種類.init(rawValue: value[1]) {
                            盤上メモ.updateValue(兵(陣営,職名), forKey: 位置)
                        }
                    }
                }
            }
        }
        
        if 盤上メモ.isEmpty == false {
            盤上 = 盤上メモ
        }
        
        
        var 手駒メモ: [王か玉か: [種類]] = [.王:[], .玉:[]]
        
        if let 💾 = 🗄.dictionary(forKey: "手駒") as? [String:[String]] {
            💾.forEach { (key: String, value: [String]) in
                value.forEach { 名 in
                    if let 職名 = 種類.init(rawValue: 名) {
                        if let 陣営 = 王か玉か.init(rawValue: key) {
                            手駒メモ[陣営]?.append(職名)
                        }
                    }
                }
            }
        }
        
        手駒 = 手駒メモ
    }
    
    
    func 書き出す() -> NSItemProvider {
        
        var 📄 = "\n☗"
        
        self.手駒[.玉]?.forEach{ ｺﾏ in
            📄 += ｺﾏ.rawValue + "͙"
        }
        
        📄 += "\n－－－－－－－－－\n"
        
        for 行 in 0 ..< 9 {
            for 列 in 0 ..< 9 {
                if let ｺﾏ = self.盤上[行*9+列] {
                    if ｺﾏ.陣営 == .玉 {
                        📄 += ｺﾏ.職名.rawValue + "͙"
                    } else {
                        📄 += ｺﾏ.職名.rawValue
                    }
                } else {
                    📄 += "　"
                }
            }
            📄 += "\n"
        }

        📄 += "－－－－－－－－－\n☖"
        
        self.手駒[.王]?.forEach{ 駒 in
            📄 += 駒.rawValue
        }
        
        return NSItemProvider(object: 📄 as NSItemProviderWriting)
    }
    
    
    func はじめに戻す() {
        self.盤上 = 初期配置
        self.手駒 = [.玉: [], .王: []]
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
