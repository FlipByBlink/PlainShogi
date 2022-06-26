
import Combine
import SwiftUI
import UniformTypeIdentifiers

class 📱AppModel: ObservableObject {
    
    @Published var 駒の配置: [Int: 将棋駒] = 初期配置
    
    //@Published var 手駒: [王側か玉側か: [駒の種類]] = 初期手駒
    @Published var 手駒: [王側か玉側か: [駒の種類: Int]] = [.王側: [:], .玉側: [:]]
    
    @Published var 持ち上げられた駒の元々の位置: Int? = nil
    
    @Published var 持ち上げられた手駒: 将棋駒? = nil
    
    @Published var 現状: 状況 = .駒を持ち上げていない
    
    @AppStorage("English表記") var 🚩English表記: Bool = false
    
    
    func 盤上の駒を持ち上げる(_ 位置: Int) -> NSItemProvider {
        持ち上げられた駒の元々の位置 = 位置
        現状 = .盤上の駒を持ち上げている
        return 外部書き出し用のテキストを準備する()
    }
    
    
    func 手駒を持ち上げる(_ 駒: 将棋駒) -> NSItemProvider {
        持ち上げられた手駒 = 駒
        現状 = .手駒を持ち上げている
        return 外部書き出し用のテキストを準備する()
    }
    
    
    func 駒をここに置く(_ 置いた位置: Int, _ 📦ItemProvider: [NSItemProvider]) -> Bool {
        
        アプリ外部からのドロップかどうか確認する(📦ItemProvider)
        
        switch 現状 {
            case .盤上の駒を持ち上げている:
                guard let 出発地点 = 持ち上げられた駒の元々の位置 else { return false }
                if 置いた位置 == 出発地点 { return false }
                
                if let 先客 = 駒の配置[置いた位置] {
                    if 先客.陣営 == 駒の配置[出発地点]?.陣営 { return true }
                    
                    手駒に加える(駒の配置[出発地点]!.陣営, 先客.職名)
                }
                
                駒の配置.updateValue(駒の配置[出発地点]!, forKey: 置いた位置)
                駒の配置.removeValue(forKey: 出発地点)
                
                持ち上げられた駒の元々の位置 = nil
            case .手駒を持ち上げている:
                guard let 駒 = 持ち上げられた手駒 else { return false }
                if 駒の配置[置いた位置] != nil { return false }
                
                駒の配置.updateValue(駒, forKey: 置いた位置)
                
                手駒から消す(駒.陣営, 駒.職名)
                
                持ち上げられた手駒 = nil
            case .駒を持ち上げていない:
                Task {
                    guard let 📦 = 📦ItemProvider.first else { return }
                    let 🅂ecureCoding = try await 📦.loadItem(forTypeIdentifier: UTType.utf8PlainText.identifier)
                    guard let 💾 = 🅂ecureCoding as? Data else { return }
                    if let 📃 = String(data: 💾, encoding: .utf8) {
                        if 📃.first == "☗" {
                            このテキストを盤面に反映する(📃)
                        }
                    }
                }
        }
        
        ログを更新する()
        
        return true
    }
    
    
    func 手駒に加える(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        //手駒[陣営]!.append(職名)
        
        if let 現在の手駒の数 = 手駒[陣営]?[職名] {
            手駒[陣営]?[職名] = 現在の手駒の数 + 1
        } else {
            手駒[陣営]?[職名] = 1
        }
        
    }
    
    func 手駒から消す(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        //手駒[陣営]!.remove(at: 手駒[陣営]!.firstIndex(of:職名)!)
        
        if let 現在の手駒の数 = 手駒[陣営]?[職名] {
            if 現在の手駒の数 >= 1 {
                手駒[陣営]?[職名] = 現在の手駒の数 - 1
            }
        } else {
            手駒[陣営]?[職名] = 0
        }
    }
    
    
    func 駒を裏返す(_ 位置: Int) {
        if let 駒 = 駒の配置[位置] {
            if let 裏 = 駒.職名.裏側 {
                駒の配置[位置] = 将棋駒(駒.陣営, 裏)
                
                振動フィードバック()
            }
        }
    }
    
    
    func ログを更新する() {
        let 🗄 = UserDefaults.standard

        var 盤上ログ: [String: [String]] = [:]

        駒の配置.forEach { (位置: Int, 駒: 将棋駒) in
            盤上ログ.updateValue([駒.陣営.rawValue, 駒.職名.rawValue], forKey: 位置.description)
        }

        🗄.set(盤上ログ, forKey: "駒の配置")

        var 手駒ログ: [String: [String: String]] = ["王側": [:], "玉側": [:]]

//        手駒.forEach { (陣営: 王側か玉側か, 駒々: [駒の種類]) in
//            駒々.forEach { 手駒ログ[陣営.rawValue]?.append($0.rawValue) }
//        }
        
        手駒[.王側]?.forEach { (駒: 駒の種類, 数: Int) in
            手駒ログ["王側"]?[駒.rawValue] = 数.description
        }
        
        手駒[.玉側]?.forEach { (駒: 駒の種類, 数: Int) in
            手駒ログ["玉側"]?[駒.rawValue] = 数.description
        }

        🗄.set(手駒ログ, forKey: "手駒")
    }
    
    
    init() {
        ログを読み込む()
    }
    
    func ログを読み込む() {
        let 🗄 = UserDefaults.standard

        var 盤上ログ: [Int: 将棋駒] = [:]

        if let 💾 = 🗄.dictionary(forKey: "駒の配置") as? [String: [String]] {
            💾.forEach { (位置: String, 駒: [String]) in
                if let 陣営 = 王側か玉側か(rawValue: 駒[0]) {
                    if let 職名 = 駒の種類(rawValue: 駒[1]) {
                        盤上ログ.updateValue(将棋駒(陣営,職名), forKey: Int(位置)!)
                    }
                }
            }
        }

        if 盤上ログ.isEmpty == false {
            駒の配置 = 盤上ログ
        }


        var 手駒ログ: [王側か玉側か: [駒の種類: Int]] = [.玉側: [:], .王側: [:]]

//        if let 💾 = 🗄.dictionary(forKey: "手駒") as? [String: [String]] {
//            💾.forEach { (陣営テキスト: String, 手駒テキスト: [String]) in
//                手駒テキスト.forEach { 駒テキスト in
//                    if let 職名 = 駒の種類(rawValue: 駒テキスト) {
//                        if let 陣営 = 王側か玉側か(rawValue: 陣営テキスト) {
//                            手駒ログ[陣営]?.append(職名)
//                        }
//                    }
//                }
//            }
//        }
        
        if let 💾 = 🗄.dictionary(forKey: "手駒") as? [String: [String: String]] {
            王側か玉側か.allCases.forEach { 陣営 in
                if let 手駒データ = 💾[陣営.rawValue] {
                    手駒データ.forEach { (職名データ: String, 数データ: String) in
                        if let 職名 = 駒の種類(rawValue: 職名データ) {
                            手駒ログ[陣営]?[職名] = Int(数データ)
                        }
                    }
                }
            }
        }

        手駒 = 手駒ログ
    }
    
    
    func 外部書き出し用のテキストを準備する() -> NSItemProvider {
        var 📄 = "\n"
        📄 += 現在の盤面をテキストに変換する()
        
        let 📦 = NSItemProvider(object: 📄 as NSItemProviderWriting)
        📦.suggestedName = "アプリ内でのコマ移動です"
        return 📦
    }
    
    
    func 現在の盤面をテキストに変換する() -> String {
        var 📄 = "☗"

//        手駒[.玉側]?.forEach{ 駒 in
//            📄 += 🚩English表記 ? 駒.Englishプレーンテキスト + "͙" : 駒.rawValue + "͙"
//        }
        
        駒の種類.allCases.forEach { 例 in
            手駒[.玉側]?.forEach { (職名: 駒の種類, 数: Int) in
                if 例 == 職名 {
                    📄 += 🚩English表記 ? 職名.Englishプレーンテキスト + "͙" : 職名.rawValue + "͙"
                    
                    if 数 >= 2 {
                        📄 += 数.description
                    }
                }
            }
        }

        📄 += "\n－－－－－－－－－\n"

        for 行 in 0 ..< 9 {
            for 列 in 0 ..< 9 {
                if let 駒 = self.駒の配置[行*9+列] {
                    📄 += 🚩English表記 ? 駒.職名.Englishプレーンテキスト : 駒.職名.rawValue

                    if 駒.陣営 == .玉側 {
                        📄 += "͙"
                    }
                } else {
                    📄 += "　"
                }
            }
            📄 += "\n"
        }

        📄 += "－－－－－－－－－\n☖"

//        手駒[.王側]?.forEach{ 駒 in
//            📄 += 🚩English表記 ? 駒.Englishプレーンテキスト : 駒.rawValue
//        }
        
        駒の種類.allCases.forEach { 例 in
            手駒[.王側]?.forEach { (職名: 駒の種類, 数: Int) in
                if 例 == 職名 {
                    📄 += 🚩English表記 ? 職名.Englishプレーンテキスト : 職名.rawValue
                    
                    if 数 >= 2 {
                        📄 += 数.description
                    }
                }
            }
        }

        return 📄
    }
    
    
    func アプリ外部からのドロップかどうか確認する(_ 📦ItemProvider: [NSItemProvider]) {
        guard let 📦 = 📦ItemProvider.first else { return }
        
        if let 🏷 = 📦.suggestedName {
            if 🏷 != "アプリ内でのコマ移動です" {
                現状 = .駒を持ち上げていない
                print("📦.suggestedName: ", 🏷)
            }
        } else {
            現状 = .駒を持ち上げていない
        }
    }
    
    
    func このテキストを盤面に反映する(_ 📃: String) {
        var 盤上テキスト: [Int: 将棋駒] = [:]
//        var 手駒テキスト = 初期手駒
        var 手駒テキスト: [王側か玉側か: [駒の種類: Int]] = [.王側: [:], .玉側: [:]]
        var 改行数: Int = 0
        var 列: Int = 0
        
        var 読み込み中の手駒の種類: 駒の種類 = .歩

        for 字区切り in 📃 {
            if 字区切り == "\n" {
                改行数 += 1
                列 = 0
                continue
            }

            let 駒テキスト = 字区切り.description

            if 改行数 == 0 {
                if let 数 = Int(駒テキスト) {
                    手駒[.玉側]?[読み込み中の手駒の種類] = 数
                } else {
                    駒の種類.allCases.forEach { 職名 in
                        if 駒テキスト == 職名.rawValue + "͙" || 駒テキスト == 職名.Englishプレーンテキスト + "͙" {
                            //手駒テキスト[.玉側]?.append(職名)
                            手駒テキスト[.玉側]?[職名] = 1
                            
                            読み込み中の手駒の種類 = 職名
                        }
                    }
                }
            }

            if 1 < 改行数 && 改行数 < 11 {
                駒の種類.allCases.forEach { 職名 in
                    let 座標 = ( 改行数 - 2 ) * 9 + 列

                    if 駒テキスト == 職名.rawValue || 駒テキスト == 職名.Englishプレーンテキスト {
                        盤上テキスト.updateValue(将棋駒(.王側, 職名), forKey: 座標)
                    }

                    if 駒テキスト == 職名.rawValue + "͙" || 駒テキスト == 職名.Englishプレーンテキスト + "͙" {
                        盤上テキスト.updateValue(将棋駒(.玉側, 職名), forKey: 座標)
                    }
                }
            }
            
            if 改行数 == 12 {
                if let 数 = Int(駒テキスト) {
                    手駒[.王側]?[読み込み中の手駒の種類] = 数
                } else {
                    駒の種類.allCases.forEach { 職名 in
                        if 駒テキスト == 職名.rawValue || 駒テキスト == 職名.Englishプレーンテキスト {
                            手駒テキスト[.王側]?[職名] = 1
                            //手駒テキスト[.王側]?.append(職名)
                            
                            読み込み中の手駒の種類 = 職名
                        }
                    }
                }
            }

            列 += 1
        }

        DispatchQueue.main.async {
            self.駒の配置 = 盤上テキスト
            self.手駒 = 手駒テキスト
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    
    func 盤面を初期化する() {
        駒の配置 = 初期配置
        //手駒 = 初期手駒
        手駒 = [.王側: [:], .玉側: [:]]
        
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}


//FIXME: > Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.
