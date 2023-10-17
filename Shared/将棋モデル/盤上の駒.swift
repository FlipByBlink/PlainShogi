struct 盤上の駒: Codable, Equatable {
    let 陣営: 王側か玉側か
    let 職名: 駒の種類
    var 成り: Bool
    mutating func 裏返す() {
        if self.職名.成駒あり { self.成り.toggle() }
    }
    init(_ ｼﾞﾝｴｲ: 王側か玉側か, _ ｼｮｸﾒｲ: 駒の種類, _ ﾅﾘ: Bool = false) {
        (self.陣営, self.職名, self.成り) = (ｼﾞﾝｴｲ, ｼｮｸﾒｲ, ﾅﾘ)
    }
}
