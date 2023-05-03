enum 🪧シートカテゴリ: Identifiable, Hashable {
    case メニュー
    case 履歴
    case ブックマーク
    case 手駒増減(王側か玉側か)
    case SharePlayガイド
    case 広告
    
    var id: Self { self }
}
