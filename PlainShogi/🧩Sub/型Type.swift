
struct 将棋駒 { //TODO: 実装見直す？
    let 陣営: 王側か玉側か
    let 職名: 駒の種類
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        陣営 = ｼﾞﾝｴｲ
        職名 = ｼｮｸﾒｲ
    }
}


enum 王側か玉側か: String, CaseIterable {
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




let 空の手駒: [王側か玉側か: [駒の種類: Int]] = [.王側: [:], .玉側: [:]]


let 初期配置: [Int: 将棋駒] =
[0:将棋駒(.玉側,.香), 1:将棋駒(.玉側,.桂), 2:将棋駒(.玉側,.銀), 3:将棋駒(.玉側,.金), 4:将棋駒(.玉側,.玉), 5:将棋駒(.玉側,.金), 6:将棋駒(.玉側,.銀), 7:将棋駒(.玉側,.桂), 8:将棋駒(.玉側,.香),
10:将棋駒(.玉側,.飛),16:将棋駒(.玉側,.角),
18:将棋駒(.玉側,.歩),19:将棋駒(.玉側,.歩),20:将棋駒(.玉側,.歩),21:将棋駒(.玉側,.歩),22:将棋駒(.玉側,.歩),23:将棋駒(.玉側,.歩),24:将棋駒(.玉側,.歩),25:将棋駒(.玉側,.歩),26:将棋駒(.玉側,.歩),

54:将棋駒(.王側,.歩),55:将棋駒(.王側,.歩),56:将棋駒(.王側,.歩),57:将棋駒(.王側,.歩),58:将棋駒(.王側,.歩),59:将棋駒(.王側,.歩),60:将棋駒(.王側,.歩),61:将棋駒(.王側,.歩),62:将棋駒(.王側,.歩),
64:将棋駒(.王側,.角),70:将棋駒(.王側,.飛),
72:将棋駒(.王側,.香),73:将棋駒(.王側,.桂),74:将棋駒(.王側,.銀),75:将棋駒(.王側,.金),76:将棋駒(.王側,.王),77:将棋駒(.王側,.金),78:将棋駒(.王側,.銀),79:将棋駒(.王側,.桂),80:将棋駒(.王側,.香)]
//FIXME: 実装方法再検討
