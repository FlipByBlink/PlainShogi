
import SwiftUI


struct 盤上に置かれた駒 {
    @EnvironmentObject var 📱: 📱AppModel
    
    let 陣営: 王側か玉側か
    let 職名: 駒の種類2
    var 成り: Bool
    
    var 表記: String {
        if 📱.🚩English表記 {
            if 成り {
                return 職名.Alphabet成駒表記!
            } else {
                return 職名.Alphabet生駒表記
            }
        } else {
            if 成り {
                return 職名.成駒表記!
            } else {
                if 陣営 == .玉側 && 職名 == .王 {
                    return "玉"
                } else {
                    return 職名.rawValue
                }
            }
        }
    }
    
    mutating func 裏返す() {
        if self.職名.成駒表記 != nil {
            self.成り.toggle()
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類2) {
        陣営 = ｼﾞﾝｴｲ
        職名 = ｼｮｸﾒｲ
        成り = false
    }
}


class 手持ちの駒 {
    var 配分: [駒の種類2: Int] = [:]
    
    func 個数(_ 駒: 駒の種類2) -> Int {
        if let 数 = 配分[駒] {
            return 数
        } else {
            return 0
        }
    }
    
    func 一個増やす(_ 駒: 駒の種類2) {
        配分[駒] = 個数(駒) + 1
    }
    
    func 一個減らす(_ 駒: 駒の種類2) {
        if 個数(駒) >= 1 {
            配分[駒] = 個数(駒) - 1
        }
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
    
    var 成りがある: Bool {
        if self.成駒表記 == nil {
            return false
        } else {
            return true
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
    
    var Alphabet成駒表記: String? {
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




let 初期配置2: [Int: 盤上に置かれた駒] = {
    var 配置: [Int: 盤上に置かれた駒] = [:]
    
    let テンプレ: [Int: (王側か玉側か, 駒の種類2)] =
    [00:(.玉側,.香),01:(.玉側,.桂),02:(.玉側,.銀),03:(.玉側,.金),04:(.玉側,.王),05:(.玉側,.金),06:(.玉側,.銀),07:(.玉側,.桂),08:(.玉側,.香),
     10:(.玉側,.飛),16:(.玉側,.角),
     18:(.玉側,.歩),19:(.玉側,.歩),20:(.玉側,.歩),21:(.玉側,.歩),22:(.玉側,.歩),23:(.玉側,.歩),24:(.玉側,.歩),25:(.玉側,.歩),26:(.玉側,.歩),
     
     54:(.王側,.歩),55:(.王側,.歩),56:(.王側,.歩),57:(.王側,.歩),58:(.王側,.歩),59:(.王側,.歩),60:(.王側,.歩),61:(.王側,.歩),62:(.王側,.歩),
     64:(.王側,.角),70:(.王側,.飛),
     72:(.王側,.香),73:(.王側,.桂),74:(.王側,.銀),75:(.王側,.金),76:(.王側,.王),77:(.王側,.金),78:(.王側,.銀),79:(.王側,.桂),80:(.王側,.香)]
    
    テンプレ.forEach { (位置: Int, 駒: (陣営: 王側か玉側か, 職名: 駒の種類2)) in
        配置[位置] = 盤上に置かれた駒(駒.陣営, 駒.職名)
    }
    
    return 配置
}()
