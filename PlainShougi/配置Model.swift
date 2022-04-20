
import Combine
import SwiftUI


let 初期配置: [Int: 兵] =
[0:兵(.玉,.香), 1:兵(.玉,.桂), 2:兵(.玉,.銀), 3:兵(.玉,.金), 4:兵(.玉,.玉), 5:兵(.玉,.金), 6:兵(.玉,.銀), 7:兵(.玉,.桂), 8:兵(.玉,.香),
 10:兵(.玉,.飛),                                                       16:兵(.玉,.角),
 18:兵(.玉,.歩),19:兵(.玉,.歩),20:兵(.玉,.歩),21:兵(.玉,.歩),22:兵(.玉,.歩),23:兵(.玉,.歩),24:兵(.玉,.歩),25:兵(.玉,.歩),26:兵(.玉,.歩),
 54:兵(.王,.歩),55:兵(.王,.歩),56:兵(.王,.歩),57:兵(.王,.歩),58:兵(.王,.歩),59:兵(.王,.歩),60:兵(.王,.歩),61:兵(.王,.歩),62:兵(.王,.歩),
 64:兵(.王,.角),                                                       70:兵(.王,.飛),
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
}


struct 兵 {
    let 陣営: 王か玉か
    let 職名: 種類
    
    init(_ zinei: 王か玉か, _ syokumei: 種類) {
        陣営 = zinei
        職名 = syokumei
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
        return NSItemProvider(object: "" as NSItemProviderWriting)
    }
    
    
    func 持ち上げる(_ これ: 兵) -> NSItemProvider {
        盤外のこれを = これ
        盤上のここから = nil
        return NSItemProvider(object: "" as NSItemProviderWriting)
    }
    
    
    func 移動(ここへ: Int) -> Bool {
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
    
    
    func はじめに戻す() {
        self.盤上 = 初期配置
        self.手駒 = [.玉: [], .王: []]
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
