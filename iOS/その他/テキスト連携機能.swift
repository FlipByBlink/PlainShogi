import Foundation

struct テキスト連携機能 {
    static func テキストに変換する(_ 局面: 局面モデル) -> String {
        let english表記 = UserDefaults.standard.bool(forKey: "English表記")
        var 値 = "☗"
        
        駒の種類.allCases.forEach { 職名 in
            if let 数 = 局面.手駒[.玉側]?.個数(職名) {
                if 数 >= 1 {
                    値 += english表記 ? Self.駒をEnglishプレーンテキストに変換(職名) : 職名.生駒表記(.玉側)
                    値 += "͙"
                }
                
                if 数 >= 2 {
                    値 += 数.description
                }
            }
        }
        
        値 += "\n－－－－－－－－－\n"
        
        for 行 in 0 ..< 9 {
            for 列 in 0 ..< 9 {
                if let 駒 = 局面.盤駒[行 * 9 + 列] {
                    if english表記 {
                        値 += Self.駒をEnglishプレーンテキストに変換(駒.職名, 駒.成り)
                    } else {
                        値 += 駒.成り ? 駒.職名.成駒表記! : 駒.職名.生駒表記(駒.陣営)
                    }
                    
                    if 駒.陣営 == .玉側 {
                        値 += "͙"
                    }
                } else {
                    値 += "　"
                }
            }
            値 += "\n"
        }
        
        値 += "－－－－－－－－－\n☖"
        
        駒の種類.allCases.forEach { 職名 in
            if let 数 = 局面.手駒[.王側]?.個数(職名) {
                if 数 >= 1 {
                    値 += english表記 ? Self.駒をEnglishプレーンテキストに変換(職名) : 職名.rawValue
                }
                
                if 数 >= 2 {
                    値 += 数.description
                }
            }
        }
        
        return 値
    }
    
    static func 局面モデルに変換する(_ テキスト: String) -> 局面モデル? {
        guard テキスト.first == "☗" else {
            print("先頭の文字が「☗」ではありません。")
            return nil
        }
        
        //var 値: 局面モデル = .init(盤駒: [:], 手駒: [:]) TODO: 再検討
        var 盤⃣駒: [Int: 盤上の駒] = [:]
        var 手⃣駒: [王側か玉側か: 持ち駒] = 空の手駒
        
        var 改行数: Int = 0
        var 列: Int = 0
        var 読み込み中の手駒の種類: 駒の種類 = .歩
        
        for 字区切り in テキスト {
            if 字区切り == "\n" {
                改行数 += 1
                列 = 0
                continue
            }
            
            let 駒テキスト = 字区切り.description
            
            switch 改行数 {
                case 0:
                    if let 数 = Int(駒テキスト) {
                        if 手⃣駒[.玉側]?.配分[読み込み中の手駒の種類] == 1 {
                            if 数 == 1 {
                                手⃣駒[.玉側]?.配分[読み込み中の手駒の種類] = 10
                            } else {
                                手⃣駒[.玉側]?.配分[読み込み中の手駒の種類] = 数
                            }
                        } else if 手⃣駒[.玉側]?.配分[読み込み中の手駒の種類] == 10 {
                            手⃣駒[.玉側]?.配分[読み込み中の手駒の種類] = 10 + 数
                        } else {
                            assertionFailure()
                        }
                        //仕様: 19個までの手駒をインポート可能
                    } else {
                        if let 駒 = Self.プレーンテキストを駒に変換(駒テキスト) {
                            手⃣駒[駒.陣営]?.配分[駒.職名] = 1
                            
                            読み込み中の手駒の種類 = 駒.職名
                        }
                    }
                case 1...11:
                    let 位置 = ( 改行数 - 2 ) * 9 + 列
                    
                    if let 駒 = Self.プレーンテキストを駒に変換(駒テキスト) {
                        盤⃣駒.updateValue(盤上の駒(駒.陣営, 駒.職名, 駒.成り), forKey: 位置)
                    }
                case 12:
                    if let 数 = Int(駒テキスト) {
                        if 手⃣駒[.王側]?.配分[読み込み中の手駒の種類] == 1 {
                            if 数 == 1 {
                                手⃣駒[.王側]?.配分[読み込み中の手駒の種類] = 10
                            } else {
                                手⃣駒[.王側]?.配分[読み込み中の手駒の種類] = 数
                            }
                        } else if 手⃣駒[.王側]?.配分[読み込み中の手駒の種類] == 10 {
                            手⃣駒[.王側]?.配分[読み込み中の手駒の種類] = 10 + 数
                        } else {
                            assertionFailure()
                        }
                        //仕様: 19個までの手駒をインポート可能
                    } else {
                        if let 駒 = Self.プレーンテキストを駒に変換(駒テキスト) {
                            手⃣駒[駒.陣営]?.配分[駒.職名] = 1
                            
                            読み込み中の手駒の種類 = 駒.職名
                        }
                    }
                default: break
            }
            
            列 += 1
        }
        
        return 局面モデル(盤駒: 盤⃣駒, 手駒: 手⃣駒)
    }
    
    private static func 駒をEnglishプレーンテキストに変換(_ 職名: 駒の種類, _ 成り: Bool = false) -> String {
        switch 職名 {
            case .歩: return 成り ? "ｐ" : "Ｐ"
            case .角: return 成り ? "ｂ" : "Ｂ"
            case .飛: return 成り ? "ｒ" : "Ｒ"
            case .香: return 成り ? "ｌ" : "Ｌ"
            case .桂: return 成り ? "ｎ" : "Ｎ"
            case .銀: return 成り ? "ｓ" : "Ｓ"
            case .金: return "Ｇ"
            case .王: return "Ｋ"
        }
    }
    
    private static func プレーンテキストを駒に変換(_ テキスト: String) -> (陣営: 王側か玉側か, 職名: 駒の種類, 成り: Bool)? {
        var 陣営: 王側か玉側か = .王側
        var 職名: 駒の種類 = .歩
        var 成り = false
        
        if テキスト.unicodeScalars.contains("͙") { 陣営 = .玉側 }
        
        if let 職名テキスト = テキスト.unicodeScalars.first?.description {
            switch 職名テキスト {
                case "歩","Ｐ": 職名 = .歩
                case "角","Ｂ": 職名 = .角
                case "飛","Ｒ": 職名 = .飛
                case "香","Ｌ": 職名 = .香
                case "桂","Ｎ": 職名 = .桂
                case "銀","Ｓ": 職名 = .銀
                case "金","Ｇ": 職名 = .金
                case "王","玉","Ｋ": 職名 = .王
                case "と","ｐ": (職名, 成り) = (.歩, true)
                case "馬","ｂ": (職名, 成り) = (.角, true)
                case "龍","ｒ": (職名, 成り) = (.飛, true)
                case "杏","ｌ": (職名, 成り) = (.香, true)
                case "圭","ｎ": (職名, 成り) = (.桂, true)
                case "全","ｓ": (職名, 成り) = (.銀, true)
                default: return nil
            }
        }
        
        return (陣営, 職名, 成り)
    }
}
