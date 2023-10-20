import Foundation

//======== 駒の「位置」 ========
//             玉
// 00,01,02,03,04,05,06,07,08
// 09,10,11,12,13,14,15,16,17
// ...
// 63,64,65,66,67,68,69,70,71
// 72,73,74,75,76,77,78,79,80
//             王
//============================

struct 局面モデル: Codable, Equatable {
    private(set) var 盤駒: [Int: 盤上の駒]
    private(set) var 手駒: [王側か玉側か: 持ち駒]
    private(set) var 直近の操作: 駒の場所 = .なし
    private(set) var 更新日時: Date?
}

extension 局面モデル {
    mutating func 駒を移動させる(_ 出発した場所: 駒の場所, _ 移動先: 駒の移動先パターン) throws {
        switch 移動先 {
            case .盤上(let 置いた位置):
                switch 出発した場所 {
                    case .盤駒(let 出発位置):
                        if 置いた位置 == 出発位置 { throw Self.駒移動エラー.無効 }
                        guard let 動かした駒 = self.盤駒[出発位置] else { throw 不特定エラー.要修正 }
                        if let 先客 = self.盤駒[置いた位置] {
                            if 先客.陣営 == 動かした駒.陣営 { throw Self.駒移動エラー.無効 }
                            self.手駒[動かした駒.陣営]?.一個増やす(先客.職名)
                        }
                        self.盤駒.removeValue(forKey: 出発位置)
                        self.盤駒.updateValue(動かした駒, forKey: 置いた位置)
                        self.ユーザー操作時の雑多処理(強調対象: .盤駒(置いた位置))
                    case .手駒(let 陣営, let 職名):
                        if self.盤駒[置いた位置] != nil { throw Self.駒移動エラー.無効 }
                        self.盤駒.updateValue(盤上の駒(陣営, 職名), forKey: 置いた位置)
                        self.手駒[陣営]?.一個減らす(職名)
                        self.ユーザー操作時の雑多処理(強調対象: .盤駒(置いた位置))
                    default:
                        throw 不特定エラー.要修正
                }
            case .盤外(let 移動先の陣営):
                switch 出発した場所 {
                    case .盤駒(let 出発地点):
                        guard let 動かした駒 = self.盤駒[出発地点] else { throw 不特定エラー.要修正 }
                        self.盤駒.removeValue(forKey: 出発地点)
                        self.手駒[移動先の陣営]?.一個増やす(動かした駒.職名)
                        self.ユーザー操作時の雑多処理(強調対象: .手駒(移動先の陣営, 動かした駒.職名))
                    case .手駒(let 移動元の陣営, let 職名):
                        self.手駒[移動元の陣営]?.一個減らす(職名)
                        self.手駒[移動先の陣営]?.一個増やす(職名)
                        self.ユーザー操作時の雑多処理(強調対象: .手駒(移動先の陣営, 職名))
                    default:
                        throw 不特定エラー.要修正
                }
        }
    }
    enum 駒移動エラー: Error {
        case 無効
    }
    func ここからここへは移動不可(_ 移動し始めた場所: 駒の場所, _ 移動先: 駒の移動先パターン) -> Bool {
        guard 移動し始めた場所 != .なし else { return true }
        switch 移動先 {
            case .盤上(let 検証位置):
                switch 移動し始めた場所 {
                    case .盤駒(let 盤駒の元々の位置):
                        if 検証位置 == 盤駒の元々の位置 {
                            return true
                        }
                        if self.盤駒[検証位置]?.陣営 == self.盤駒[盤駒の元々の位置]?.陣営 {
                            return true
                        }
                        return false
                    case .手駒(_, _):
                        return self.盤駒[検証位置] != nil
                    case .なし:
                        assertionFailure(); return false
                }
            case .盤外(let 移動した先の陣営):
                switch 移動し始めた場所 {
                    case .盤駒(_):
                        return false
                    case .手駒(let 元々の陣営, _):
                        return 移動した先の陣営 == 元々の陣営
                    case .なし:
                        assertionFailure(); return false
                }
        }
    }
    func ここに駒がある(_ 場所: 駒の場所) -> Bool {
        switch 場所 {
            case .盤駒(let 位置): self.盤駒[位置] != nil
            case .手駒(_, _): self.この手駒の数(場所) > 0
            default: false
        }
    }
    func この駒の表記(_ 場所: 駒の場所, _ english表記: Bool) -> String? {
        guard let 職名表記 = self.この駒の職名表記(場所, english表記) else { return nil }
        if case .手駒(_, _) = 場所 {
            switch self.この手駒の数(場所) {
                case 1: return 職名表記
                case 2...: return 職名表記 + self.この手駒の数(場所).description
                default: return nil
            }
        } else {
            return 職名表記
        }
    }
    func この駒の職名表記(_ 場所: 駒の場所, _ english表記: Bool) -> String? {
        switch 場所 {
            case .盤駒(let 位置):
                guard let 駒 = self.盤駒[位置] else { return nil }
                if english表記 {
                    return 駒.成り ? 駒.職名.english成駒表記 : 駒.職名.english生駒表記
                } else {
                    return 駒.成り ? 駒.職名.成駒表記 : 駒.職名.生駒表記(駒.陣営)
                }
            case .手駒(let 陣営, let 職名):
                if !english表記, 陣営 == .玉側, 職名 == .王 {
                    return "玉"
                } else {
                    return english表記 ? 職名.english生駒表記 : 職名.rawValue
                }
            case .なし:
                return nil
        }
    }
    func この駒の陣営(_ 場所: 駒の場所) -> 王側か玉側か? {
        switch 場所 {
            case .盤駒(let 位置): self.盤駒[位置]?.陣営
            case .手駒(let 陣営, _): 陣営
            case .なし: nil
        }
    }
    func これとこれは同じ陣営(_ 場所1: 駒の場所, _ 場所2: 駒の場所) -> Bool {
        self.この駒の陣営(場所1) == self.この駒の陣営(場所2)
    }
    func この手駒の数(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> Int {
        self.手駒[陣営]?.個数(職名) ?? 0
    }
    func この手駒の数(_ 場所: 駒の場所) -> Int {
        switch 場所 {
            case .手駒(let 陣営, let 職名): return self.この手駒の数(陣営, 職名)
            default: assertionFailure(); return 0
        }
    }
    func この駒の陣営の手駒の種類の数(_ 場所: 駒の場所) -> Int {
        guard let 陣営 = self.この駒の陣営(場所) else { return 0 }
        return 駒の種類.allCases.reduce(into: 0) {
            if self.この手駒の数(陣営, $1) > 0 { $0 += 1 }
        }
    }
    func この駒にはアンダーラインが必要(_ 場所: 駒の場所, _ english表記: Bool) -> Bool {
        guard english表記,
              case .盤駒(let 位置) = 場所,
              let 駒 = self.盤駒[位置],
              駒.陣営 == .玉側,
              [.銀, .桂].contains(駒.職名) else { return false }
        return true
    }
    func この駒移動で成る事が可能(_ 移動後の場所: 駒の場所, _ 元々の場所: 駒の場所) -> Bool {
        if case (.盤駒(let 移動先), .盤駒(let 元々の位置)) = (移動後の場所, 元々の場所) {
            if let 移動後の駒 = self.盤駒[移動先] {
                if 移動後の駒.成り == false {
                    if 移動後の駒.職名.成駒あり {
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
        }
        return false
    }
    func この駒は成る事ができる(_ 位置: Int) -> Bool {
        self.盤駒[位置]?.職名.成駒あり == true
    }
    mutating func この駒を裏返す(_ 位置: Int) {
        if self.この駒は成る事ができる(位置) {
            self.盤駒[位置]?.裏返す()
            self.ユーザー操作時の雑多処理(強調対象: .盤駒(位置))
        }
    }
    func 増減モードでこの手駒を増やすことが出来る(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> Bool {
        self.この手駒の数(.手駒(陣営, 職名)) < 19
    }
    mutating func 増減モードでこの手駒を一個増やす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        guard self.増減モードでこの手駒を増やすことが出来る(陣営, 職名) else { return }
        self.手駒[陣営]?.一個増やす(職名)
        self.ユーザー操作時の雑多処理(強調対象: .手駒(陣営, 職名))
    }
    func 増減モードでこの手駒を減らすことが出来る(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) -> Bool {
        self.この手駒の数(.手駒(陣営, 職名)) >= 0
    }
    mutating func 増減モードでこの手駒を一個減らす(_ 陣営: 王側か玉側か, _ 職名: 駒の種類) {
        guard self.増減モードでこの手駒を減らすことが出来る(陣営, 職名) else { return }
        self.手駒[陣営]?.一個減らす(職名)
        self.ユーザー操作時の雑多処理(強調対象: .手駒(陣営, 職名))
    }
    mutating func 増減モードでこの盤駒を消す(_ 位置: Int) {
        self.盤駒.removeValue(forKey: 位置)
        self.ユーザー操作時の雑多処理(強調対象: .盤駒(位置))
    }
    mutating func 直近操作情報を消す() {
        self.ユーザー操作時の雑多処理(強調対象: .なし)
    }
    mutating func 初期化する() {
        self = .初期セット
        self.ユーザー操作時の雑多処理(強調対象: .なし)
    }
    //SharePlayデータ受け取り時
    mutating func 更新日時を変更せずにモデルを適用する(_ 新規局面: Self) {
        self = 新規局面
        self.現在の局面を履歴に追加する()
    }
    //履歴復元時、インポートデータ適用時
    mutating func 現在の局面として適用する(_ 新規局面: Self) {
        self = 新規局面
        self.更新日時 = .now
        self.現在の局面を履歴に追加する()
    }
    mutating func 何も無い状態に変更する() {
        self = Self(盤駒: [:], 手駒: [:])
        self.現在の局面を履歴に追加する()
    }
    static var 履歴: [Self] {
        guard let data = ICloudデータ.data(key: "履歴") else { return [] }
        do {
            return try JSONDecoder().decode([Self].self, from: data)
        } catch {
            assertionFailure(); return []
        }
    }
    static var 前回の局面: Self? { Self.履歴.last }
    var 一手前の局面: Self? { Self.履歴.last { $0 != self } }
    static func 履歴を全て削除する() { ICloudデータ.remove(key: "履歴") }
    func 現在の局面をブックマークする() { ICloudデータ.set(self.エンコード(), key: "ブックマーク") }
    static func ブックマークを読み込む() -> Self? { .デコード(ICloudデータ.data(key: "ブックマーク")) }
    func エンコード() -> Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            assertionFailure(); return Data()
        }
    }
    static func デコード(_ データ: Data?) -> Self? {
        guard let データ else { return nil }
        do {
            return try JSONDecoder().decode(Self.self, from: データ)
        } catch {
            assertionFailure(); return nil
        }
    }
    var 更新日付表記: String { self.更新日時?.formatted(.dateTime.day().month()) ?? "⚠︎" }
    var 更新時刻表記: String { self.更新日時?.formatted(.dateTime.hour().minute().second()) ?? "⚠︎" }
    var SharePlay共有可能: Bool { self.更新日時 != nil }
    var 駒が1つも無い: Bool { self == Self(盤駒: [:], 手駒: [:]) }
    static var 履歴メニュー上での表示対象: [Self] { Self.履歴.reversed().filter { $0.更新日時 != nil } }
    static var 初期セット: Self { Self(盤駒: Self.初期配置, 手駒: 空の手駒) }
}

private extension 局面モデル {
    private mutating func ユーザー操作時の雑多処理(強調対象: 駒の場所) {
        self.直近の操作 = 強調対象
        self.更新日時 = .now
        self.現在の局面を履歴に追加する()
    }
    private func 現在の局面を履歴に追加する() {
        //レスポンス改善(特にwatchOS)のためにTask分離
        Task(priority: .low) {
            var 新しい履歴: [Self]
            新しい履歴 = Self.履歴
            if 新しい履歴.count > 30 { 新しい履歴.removeFirst() }
            新しい履歴 += [self]
            do {
                let data = try JSONEncoder().encode(新しい履歴)
                ICloudデータ.set(data, key: "履歴")
                ICloudデータ.synchronize()
            } catch {
                assertionFailure()
            }
        }
    }
    private static let 初期配置: [Int: 盤上の駒] = {
        var 値: [Int: 盤上の駒] = [:]
        let テンプレ: [Int: (王側か玉側か, 駒の種類)] = {
            [00:(.玉側,.香),01:(.玉側,.桂),02:(.玉側,.銀),03:(.玉側,.金),04:(.玉側,.王),05:(.玉側,.金),06:(.玉側,.銀),07:(.玉側,.桂),08:(.玉側,.香),
                           10:(.玉側,.飛),                                                                     16:(.玉側,.角),
             18:(.玉側,.歩),19:(.玉側,.歩),20:(.玉側,.歩),21:(.玉側,.歩),22:(.玉側,.歩),23:(.玉側,.歩),24:(.玉側,.歩),25:(.玉側,.歩),26:(.玉側,.歩),
             
             54:(.王側,.歩),55:(.王側,.歩),56:(.王側,.歩),57:(.王側,.歩),58:(.王側,.歩),59:(.王側,.歩),60:(.王側,.歩),61:(.王側,.歩),62:(.王側,.歩),
                           64:(.王側,.角),                                                                     70:(.王側,.飛),
             72:(.王側,.香),73:(.王側,.桂),74:(.王側,.銀),75:(.王側,.金),76:(.王側,.王),77:(.王側,.金),78:(.王側,.銀),79:(.王側,.桂),80:(.王側,.香)]
        }()
        テンプレ.forEach { 値[$0.key] = 盤上の駒($0.value.0, $0.value.1) }
        return 値
    }()
}
