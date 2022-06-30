
import SwiftUI


struct 盤上に置かれた駒 {
    @EnvironmentObject var 📱: 📱AppModel
    
    let 陣営: 王側か玉側か
    let 職名: 駒の種類2
    let 成り: Bool
    
    var 表記: String {
        if 📱.🚩English表記 {
            if 成り {
                return 職名.Alphabet成駒表記
            } else {
                return 職名.Alphabet生駒表記
            }
        } else {
            if 成り {
                return 職名.成駒表記
            } else {
                if 陣営 == .玉側 && 職名 == .王 {
                    return "玉"
                } else {
                    return 職名.rawValue
                }
            }
        }
    }
}


struct 手持ちの駒 {
    let 配分: [駒の種類2: Int] = [.歩:4, .角:1]
    
    func 個数(_ 駒: 駒の種類2) -> Int {
        if let 数 = 配分[駒] {
            return 数
        } else {
            return 0
        }
    }
    
    func 一個増やす(_ 駒: 駒の種類2) {
        //
    }
    
    func 一個減らす(_ 駒: 駒の種類2) {
        //
    }
}


enum 駒の種類2: String, CaseIterable, Identifiable {
    
    case 歩
    case 角
    case 飛
    case 香
    case 桂
    case 銀
    case 金
    case 王
    
    var id: Self { self }
    
    var 成駒表記: String {
        switch self {
            case .歩: return "と"
            case .角: return "馬"
            case .飛: return "龍"
            case .香: return "杏"
            case .桂: return "圭"
            case .銀: return "全"
            default: return "🐛" //Bug
        }
    }
    
    var Alphabet生駒表記: String {
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
    
    var Alphabet成駒表記: String {
        switch self {
            case .歩: return "+P"
            case .角: return "+B"
            case .飛: return "+R"
            case .香: return "+L"
            case .桂: return "+N"
            case .銀: return "+S"
            default: return "🐛" //Bug
        }
    }
}
