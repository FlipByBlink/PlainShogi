import Foundation

//             玉
// 00,01,02,03,04,05,06,07,08
// 09,10,11,12,13,14,15,16,17
// ...
// 63,64,65,66,67,68,69,70,71
// 72,73,74,75,76,77,78,79,80
//             王

struct 局面モデル: Codable {
    private(set) var 盤駒: [Int: 盤上の駒]
    private(set) var 手駒: [王側か玉側か: 持ち駒]
    private(set) var 盤駒の通常移動直後の駒: 通常移動直後情報?
    private(set) var 更新日時: Date?
    
    mutating func 盤駒を移動させる(_ 出発地点: Int, _ 置いた位置: Int) throws {
        if 置いた位置 == 出発地点 { throw 🚨駒移動エラー.無効 }
        guard let 動かした駒 = self.盤駒[出発地点] else { throw 🚨エラー.要修正 }
        var 取った駒: 駒の種類? = nil
        if let 先客 = self.盤駒[置いた位置] {
            if 先客.陣営 == 動かした駒.陣営 { throw 🚨駒移動エラー.無効 }
            self.手駒[動かした駒.陣営]?.一個増やす(先客.職名)
            取った駒 = 先客.職名
        }
        self.盤駒.removeValue(forKey: 出発地点)
        self.盤駒.updateValue(動かした駒, forKey: 置いた位置)
        self.盤駒の通常移動直後の駒 = 通常移動直後情報(置いた位置, 取った駒)
    }
    
    mutating func 持ち駒を盤上へ移動させる(_ 元の駒: 盤外の駒, _ 置いた位置: Int) throws {
        if self.盤駒[置いた位置] != nil { throw 🚨駒移動エラー.無効 }
        self.盤駒.updateValue(盤上の駒(元の駒.陣営, 元の駒.職名), forKey: 置いた位置)
        self.手駒[元の駒.陣営]?.一個減らす(元の駒.職名)
        self.盤駒の通常移動直後の駒 = 通常移動直後情報(置いた位置, nil)
    }
    
    mutating func 盤駒を盤外へ移動させる(_ 出発地点: Int, _ 移動先の陣営: 王側か玉側か) throws {
        guard let 動かした駒 = self.盤駒[出発地点] else { throw 🚨エラー.要修正 }
        self.盤駒.removeValue(forKey: 出発地点)
        self.手駒[移動先の陣営]?.一個増やす(動かした駒.職名)
        self.盤駒通常移動直後情報を消す()
    }
    
    mutating func 持ち駒を敵の持ち駒に移動させる(_ 元の駒: 盤外の駒, _ 移動先の陣営: 王側か玉側か) {
        self.手駒[元の駒.陣営]?.一個減らす(元の駒.職名)
        self.手駒[移動先の陣営]?.一個増やす(元の駒.職名)
        self.盤駒通常移動直後情報を消す()
    }
    
    enum 🚨駒移動エラー: Error {
        case 無効
    }
    
    func 盤上のこの駒の表記(_ 位置: Int, _ English表記: Bool) -> String? {
        guard let 駒 = self.盤駒[位置] else { return nil }
        if English表記 {
            return 駒.成り ? 駒.職名.English成駒表記 : 駒.職名.English生駒表記
        } else {
            if (駒.陣営 == .玉側) && (駒.職名 == .王) {
                return "玉"
            } else {
                return 駒.成り ? 駒.職名.成駒表記 : 駒.職名.rawValue
            }
        }
    }
    
    func この駒の成りについて判断すべき(_ 移動先: Int, _ 元々の位置: Int?) -> Bool {
        guard let 元々の位置 else { return false }
        if let 移動後の駒 = self.盤駒[移動先] {
            if 移動後の駒.成り == false {
                if 移動後の駒.職名.成駒表記 != nil {
                    switch 移動後の駒.陣営 {
                        case .王側:
                            if 移動先 < 27 { return true }
                            if 元々の位置 < 27 { return true }
                        case .玉側:
                            if 53 < 移動先 { return true }
                            if 53 < 元々の位置 { return true }
                    }
                }
            }
        }
        return false
    }
    
    mutating func この駒を裏返す(_ 位置: Int) {
        self.盤駒[位置]?.裏返す()
        if self.盤駒の通常移動直後の駒?.盤上の位置 != 位置 {
            self.盤駒通常移動直後情報を消す()
        }
    }
    
    mutating func この手駒を一個増やす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.手駒[陣営]?.一個増やす(職名)
        self.盤駒通常移動直後情報を消す()
    }
    
    mutating func この手駒を一個減らす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        self.手駒[陣営]?.一個減らす(職名)
        self.盤駒通常移動直後情報を消す()
    }
    
    mutating func この盤駒を消す(_ 位置: Int) {
        self.盤駒.removeValue(forKey: 位置)
        self.盤駒通常移動直後情報を消す()
    }
    
    mutating func 盤駒通常移動直後情報を消す() {
        self.盤駒の通常移動直後の駒 = nil
    }
    
    mutating func 初期化する() {
        self = .初期セット
    }
    
    mutating func 現在の局面を履歴に追加する() {
        self.更新日時 = .now
        do {
            let ⓔncoder = JSONEncoder()
            let ⓓata = try ⓔncoder.encode(Self.履歴 + [self])
            UserDefaults.standard.set(ⓓata, forKey: "履歴")
        } catch {
            print("🚨", error.localizedDescription)
        }
    }
    
    static var 履歴: [Self] {
        if let ⓓata = UserDefaults.standard.data(forKey: "履歴") {
            do {
                let ⓓecoder = JSONDecoder()
                return try ⓓecoder.decode([Self].self, from: ⓓata)
            } catch {
                print("🚨", error.localizedDescription)
                return []
            }
        } else {
            return []
        }
    }
    
    static func 履歴を全て削除する() {
        UserDefaults.standard.removeObject(forKey: "履歴")
    }
    
    static var 初期セット: Self {
        Self(盤駒: 初期配置, 手駒: 空の手駒, 盤駒の通常移動直後の駒: nil)
    }
}

enum 王側か玉側か: String, CaseIterable, Codable {
    case 王側
    case 玉側
}

struct 盤上の駒: Codable {
    let 陣営: 王側か玉側か
    let 職名: 駒の種類
    var 成り: Bool
    
    mutating func 裏返す() {
        if self.職名.成駒表記 != nil {
            self.成り.toggle()
        }
    }
    
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類, _ ﾅﾘ: Bool = false) {
        (self.陣営, self.職名, self.成り) = (ｼﾞﾝｴｲ, ｼｮｸﾒｲ, ﾅﾘ)
    }
}

struct 持ち駒: Codable {
    var 配分: [駒の種類: Int] = [:]
    
    func 個数(_ 職名: 駒の種類) -> Int {
        self.配分[職名] ?? 0
    }
    
    static var 空: Self {
        Self(配分: [:])
    }
    
    mutating func 一個増やす(_ 職名: 駒の種類) {
        self.配分[職名] = self.個数(職名) + 1
    }
    
    mutating func 一個減らす(_ 職名: 駒の種類) {
        if self.個数(職名) >= 1 {
            self.配分[職名] = self.個数(職名) - 1
        }
    }
}

struct 盤外の駒 {
    var 陣営: 王側か玉側か
    var 職名: 駒の種類
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類) {
        (self.陣営, self.職名) = (ｼﾞﾝｴｲ, ｼｮｸﾒｲ)
    }
}

enum 駒の種類: String, CaseIterable, Identifiable, Codable {
    case 歩, 角, 飛, 香, 桂, 銀, 金, 王
    
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

struct 通常移動直後情報: Codable {
    var 盤上の位置: Int
    var 取った持ち駒: 駒の種類?
    init(_ ｲﾁ: Int, _ ﾓﾁｺﾞﾏ: 駒の種類?) {
        (self.盤上の位置, self.取った持ち駒) = (ｲﾁ, ﾓﾁｺﾞﾏ)
    }
}

let 空の手駒: [王側か玉側か: 持ち駒] = [.王側: 持ち駒.空, .玉側: 持ち駒.空]

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

//MARK: 一般的な将棋慣習
//「玉」が手前で「王」が対面のことが多い。逆が珍しいわけではない。
//図示する際は「先手」が手前で「後手」が対面のことがほとんど。
//図示する際に両方「玉」のことがたまにある。
//「先手(手前?)」を黒い駒 ☗ 、「後手(対面?)」を白い駒 ☖ で表すことが多い(っぽい)。
//プレーンテキストでの局面図表現のデファクトスタンダードとしてBOD形式というのがあるらしい。
