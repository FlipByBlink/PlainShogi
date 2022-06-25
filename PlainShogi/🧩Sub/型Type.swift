
struct 兵 {
    let 陣営: 王側か玉側か
    let 職名: 駒の種類
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        陣営 = ｼﾞﾝｴｲ
        職名 = ｼｮｸﾒｲ
    }
}


enum 王側か玉側か: String {
    case 王側
    case 玉側
}


enum 状況 {
    case 駒を持ち上げていない
    case 盤上の駒を持ち上げている
    case 手駒を持ち上げている
}


enum 駒の種類: String, CaseIterable, Identifiable {
    
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
    
    var English表記: String {
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
    
    var Englishプレーンテキスト: String {
        switch self {
        case .歩: return "Ｐ"
        case .と: return "ｐ"
        case .角: return "Ｂ"
        case .馬: return "ｂ"
        case .飛: return "Ｒ"
        case .龍: return "ｒ"
        case .香: return "Ｌ"
        case .杏: return "ｌ"
        case .桂: return "Ｎ"
        case .圭: return "ｎ"
        case .銀: return "Ｓ"
        case .全: return "ｓ"
        case .金: return "Ｇ"
        case .王: return "Ｋ"
        case .玉: return "Ｋ"
        }
    }
}


let 初期手駒: [王側か玉側か: [駒の種類]] = [.玉側: [], .王側: []]


let 初期配置: [Int: 兵] =
[0:兵(.玉側,.香), 1:兵(.玉側,.桂), 2:兵(.玉側,.銀), 3:兵(.玉側,.金), 4:兵(.玉側,.玉), 5:兵(.玉側,.金), 6:兵(.玉側,.銀), 7:兵(.玉側,.桂), 8:兵(.玉側,.香),
               10:兵(.玉側,.飛),                                                                              16:兵(.玉側,.角),
18:兵(.玉側,.歩),19:兵(.玉側,.歩),20:兵(.玉側,.歩),21:兵(.玉側,.歩),22:兵(.玉側,.歩),23:兵(.玉側,.歩),24:兵(.玉側,.歩),25:兵(.玉側,.歩),26:兵(.玉側,.歩),

54:兵(.王側,.歩),55:兵(.王側,.歩),56:兵(.王側,.歩),57:兵(.王側,.歩),58:兵(.王側,.歩),59:兵(.王側,.歩),60:兵(.王側,.歩),61:兵(.王側,.歩),62:兵(.王側,.歩),
               64:兵(.王側,.角),                                                                              70:兵(.王側,.飛),
72:兵(.王側,.香),73:兵(.王側,.桂),74:兵(.王側,.銀),75:兵(.王側,.金),76:兵(.王側,.王),77:兵(.王側,.金),78:兵(.王側,.銀),79:兵(.王側,.桂),80:兵(.王側,.香)]
