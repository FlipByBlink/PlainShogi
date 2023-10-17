enum 駒の場所: Codable, Equatable {
    case 盤駒(_ 位置: Int)
    case 手駒(_ 陣営: 王側か玉側か, _ 職名: 駒の種類)
    case なし
}
