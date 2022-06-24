
struct 兵 {
    let 陣営: 王か玉か
    let 職名: 種類
    
    init(_ ｼﾞﾝｴｲ: 王か玉か, _ ｼｮｸﾒｲ: 種類) {
        陣営 = ｼﾞﾝｴｲ
        職名 = ｼｮｸﾒｲ
    }
}


enum 王か玉か: String {
    case 王
    case 玉
}


enum 段階 {
    case 駒を持っていない
    case 盤上の駒を持ち上げている
    case 手駒を持ち上げている
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
    
    var englishテキスト: String {
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
