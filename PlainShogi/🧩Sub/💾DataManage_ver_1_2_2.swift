import Foundation

struct データ管理_ver_1_2_2 {
    static var 以前のデータがあるか: Bool {
        UserDefaults.standard.dictionary(forKey: "駒の配置") != nil
        &&
        UserDefaults.standard.dictionary(forKey: "手駒") != nil
    }
    
    static func 以前のデータを削除する() {
        UserDefaults.standard.removeObject(forKey: "駒の配置")
        UserDefaults.standard.removeObject(forKey: "手駒")
    }
    
    static func 以前アプリ起動した際のログを読み込む() -> 局面モデル {
        let 💾 = UserDefaults.standard
        var 駒の配置: [Int: 盤上の駒] = [:]
        var 手駒: [王側か玉側か: 持ち駒] = 空の手駒
        
        if let 駒⃣の配置 = 💾.dictionary(forKey: "駒の配置") as? [String: [String]] {
            if let 手⃣駒 = 💾.dictionary(forKey: "手駒") as? [String: [String: String]] {
                駒⃣の配置.forEach { (位置テキスト: String, 駒テキスト: [String]) in
                    if 駒テキスト.count != 3 { return }
                    if let 陣営 = 王側か玉側か(rawValue: 駒テキスト[0]) {
                        if let 職名 = 駒の種類(rawValue: 駒テキスト[1]) {
                            if let 位置 = Int(位置テキスト) {
                                if let 成り = Bool(駒テキスト[2]) {
                                    駒の配置.updateValue(盤上の駒(陣営, 職名, 成り), forKey: 位置)
                                } else {
                                    駒の配置.updateValue(盤上の駒(陣営, 職名), forKey: 位置)
                                }
                            }
                        }
                    }
                }
                
                王側か玉側か.allCases.forEach { 陣営 in
                    if let 手駒テキスト = 手⃣駒[陣営.rawValue] {
                        手駒テキスト.forEach { (職名テキスト: String, 数テキスト: String) in
                            if let 職名 = 駒の種類(rawValue: 職名テキスト) {
                                if let 数 = Int(数テキスト) {
                                    手駒[陣営]?.配分.updateValue(数, forKey: 職名)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return 局面モデル(盤駒: 駒の配置, 手駒: 手駒)
    }
    
    static func 更新する(駒の配置: [Int: 盤上の駒], 手駒: [王側か玉側か: 持ち駒]) {
        var 駒⃣の配置: [String: [String]] = [:]
        var 手⃣駒: [String: [String: String]] = ["王側": [:], "玉側": [:]]
        
        駒の配置.forEach { (位置: Int, 駒: 盤上の駒) in
            駒⃣の配置.updateValue([駒.陣営.rawValue, 駒.職名.rawValue, 駒.成り.description], forKey: 位置.description)
        }
        
        王側か玉側か.allCases.forEach { 陣営 in
            手駒[陣営]?.配分.forEach { (職名: 駒の種類, 数: Int) in
                手⃣駒[陣営.rawValue]?[職名.rawValue] = 数.description
            }
        }
        
        UserDefaults.standard.set(駒⃣の配置, forKey: "駒の配置")
        UserDefaults.standard.set(手⃣駒, forKey: "手駒")
    }
}
