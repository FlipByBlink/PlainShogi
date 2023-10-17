enum 駒の種類: String, CaseIterable, Identifiable, Codable {
    case 歩, 角, 飛, 香, 桂, 銀, 金, 王
}

extension 駒の種類 {
    var id: Self { self }
    func 生駒表記(_ 陣営: 王側か玉側か) -> String {
        if 陣営 == .玉側, self == .王 {
            "玉"
        } else {
            self.rawValue
        }
    }
    var 成駒表記: String? {
        switch self {
            case .歩: "と"
            case .角: "馬"
            case .飛: "龍"
            case .香: "杏"
            case .桂: "圭"
            case .銀: "全"
            default: nil
        }
    }
    var 成駒あり: Bool { 
        self.成駒表記 != nil
    }
    var english生駒表記: String {
        switch self {
            case .歩: "P"
            case .角: "B"
            case .飛: "R"
            case .香: "L"
            case .桂: "N"//見分けるために目印を付ける必要あり
            case .銀: "S"//見分けるために目印を付ける必要あり
            case .金: "G"
            case .王: "K"
        }
    }
    var english成駒表記: String? {
        switch self {
            case .歩: "+P"
            case .角: "+B"
            case .飛: "+R"
            case .香: "+L"
            case .桂: "+N"
            case .銀: "+S"
            default: nil
        }
    }
}
