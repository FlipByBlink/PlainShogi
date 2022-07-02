
enum 王側か玉側か: String, CaseIterable {
    case 王側
    case 玉側
}


enum 状況 {
    case 駒を持ち上げていない
    case 盤上の駒を持ち上げている
    case 手駒を持ち上げている
}


struct 盤上の駒 {
    let 陣営: 王側か玉側か
    let 職名: 駒の種類
    var 成り: Bool
    
    mutating func 裏返す() {
        if 職名.成駒表記 != nil {
            成り.toggle()
            振動フィードバック()
        }
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        陣営 = ｼﾞﾝｴｲ
        職名 = ｼｮｸﾒｲ
        成り = false
    }
}


struct 手持ちの駒 {
    var 配分: [駒の種類: Int] = [:]
    
    func 個数(_ 職名: 駒の種類) -> Int {
        if let 数 = 配分[職名] {
            return 数
        } else {
            return 0
        }
    }
    
    mutating func 一個増やす(_ 職名: 駒の種類) {
        配分[職名] = 個数(職名) + 1
    }
    
    mutating func 一個減らす(_ 職名: 駒の種類) {
        if 個数(職名) >= 1 {
            配分[職名] = 個数(職名) - 1
        }
    }
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
    
    var id: Self { self }
    
    var 成駒表記: String? {
        switch self {
            case .歩: return "と"
            case .角: return "馬"
            case .飛: return "龍"
            case .香: return "杏"
            case .桂: return "圭"
            case .銀: return "全"
            default: return nil
        }
    }
    
    var English生駒表記: String {
        switch self {
            case .歩: return "P"
            case .角: return "B"
            case .飛: return "R"
            case .香: return "L"
            case .桂: return "N"
            case .銀: return "S"
            case .金: return "G"
            case .王: return "K"
        }
    }
    
    var English成駒表記: String? {
        switch self {
            case .歩: return "+P"
            case .角: return "+B"
            case .飛: return "+R"
            case .香: return "+L"
            case .桂: return "+N"
            case .銀: return "+S"
            default: return nil
        }
    }
}




let 空の手駒: [王側か玉側か: 手持ちの駒] = [.王側: 手持ちの駒(), .玉側: 手持ちの駒()]




let 初期配置: [Int: 盤上の駒] = {
    var 配置: [Int: 盤上の駒] = [:]
    
    let テンプレ: [Int: (王側か玉側か, 駒の種類)] =
    [00:(.玉側,.香),01:(.玉側,.桂),02:(.玉側,.銀),03:(.玉側,.金),04:(.玉側,.王),05:(.玉側,.金),06:(.玉側,.銀),07:(.玉側,.桂),08:(.玉側,.香),
                   10:(.玉側,.飛),                                                                     16:(.玉側,.角),
     18:(.玉側,.歩),19:(.玉側,.歩),20:(.玉側,.歩),21:(.玉側,.歩),22:(.玉側,.歩),23:(.玉側,.歩),24:(.玉側,.歩),25:(.玉側,.歩),26:(.玉側,.歩),
     
     54:(.王側,.歩),55:(.王側,.歩),56:(.王側,.歩),57:(.王側,.歩),58:(.王側,.歩),59:(.王側,.歩),60:(.王側,.歩),61:(.王側,.歩),62:(.王側,.歩),
                   64:(.王側,.角),                                                                     70:(.王側,.飛),
     72:(.王側,.香),73:(.王側,.桂),74:(.王側,.銀),75:(.王側,.金),76:(.王側,.王),77:(.王側,.金),78:(.王側,.銀),79:(.王側,.桂),80:(.王側,.香)]
    
    
    テンプレ.forEach { (位置: Int, 駒: (陣営: 王側か玉側か, 職名: 駒の種類)) in
        配置[位置] = 盤上の駒(駒.陣営, 駒.職名)
    }
    
    return 配置
}()




//enum 駒の種類: String, CaseIterable, Identifiable {
//
//    case 歩
//    case 角
//    case 飛
//    case 香
//    case 桂
//    case 銀
//    case 金
//    case 王
//    case 玉
//
//    case と
//    case 馬
//    case 龍
//    case 杏 //成香
//    case 圭 //成桂
//    case 全 //成銀
//
//    var id: String { self.rawValue }
//
//    var 裏側: Self? {
//        switch self {
//        case .歩: return .と
//        case .と: return .歩
//        case .角: return .馬
//        case .馬: return .角
//        case .飛: return .龍
//        case .龍: return .飛
//        case .香: return .杏
//        case .杏: return .香
//        case .桂: return .圭
//        case .圭: return .桂
//        case .銀: return .全
//        case .全: return .銀
//        default: return nil
//        }
//    }
//
//    var 生駒: Self {
//        switch self {
//        case .と: return .歩
//        case .馬: return .角
//        case .龍: return .飛
//        case .杏: return .香
//        case .圭: return .桂
//        case .全: return .銀
//        default: return self
//        }
//    }
//
//    var English表記: String {
//        switch self {
//        case .歩: return "P"
//        case .と: return "+P"
//        case .角: return "B"
//        case .馬: return "+B"
//        case .飛: return "R"
//        case .龍: return "+R"
//        case .香: return "L"
//        case .杏: return "+L"
//        case .桂: return "N"
//        case .圭: return "+N"
//        case .銀: return "S"
//        case .全: return "+S"
//        case .金: return "G"
//        case .王: return "K"
//        case .玉: return "K"
//        }
//    }
//
//    var Englishプレーンテキスト: String {
//        switch self {
//        case .歩: return "Ｐ"
//        case .と: return "ｐ"
//        case .角: return "Ｂ"
//        case .馬: return "ｂ"
//        case .飛: return "Ｒ"
//        case .龍: return "ｒ"
//        case .香: return "Ｌ"
//        case .杏: return "ｌ"
//        case .桂: return "Ｎ"
//        case .圭: return "ｎ"
//        case .銀: return "Ｓ"
//        case .全: return "ｓ"
//        case .金: return "Ｇ"
//        case .王: return "Ｋ"
//        case .玉: return "Ｋ"
//        }
//    }
//}
