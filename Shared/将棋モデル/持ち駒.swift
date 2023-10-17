struct 持ち駒: Codable, Equatable {
    var 配分: [駒の種類: Int] = [:]
    func 個数(_ 職名: 駒の種類) -> Int { self.配分[職名] ?? 0 }
    static var 空: Self { Self(配分: [:]) }
    mutating func 一個増やす(_ 職名: 駒の種類) {
        self.配分[職名] = self.個数(職名) + 1
    }
    mutating func 一個減らす(_ 職名: 駒の種類) {
        if self.個数(職名) >= 1 {
            self.配分[職名] = self.個数(職名) - 1
        }
    }
}
