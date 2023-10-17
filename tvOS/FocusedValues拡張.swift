import SwiftUI

extension FocusedValues {
    var 将棋盤フォーカス値: Self.将棋盤フォーカスキー.Value? {
        get { self[Self.将棋盤フォーカスキー.self] }
        set { self[Self.将棋盤フォーカスキー.self] = newValue }
    }
    struct 将棋盤フォーカスキー: FocusedValueKey { typealias Value = フォーカス対象 }
    enum フォーカス対象: Equatable {
        case 盤上(_ 位置: Int)
        case 手駒(_ 陣営: 王側か玉側か, _ 職名: 駒の種類)
        case 手駒エリア全体
    }
    //@FocusedValue(\.将棋盤フォーカス値) private var 現在のフォーカス
    //"focusable"の外側に"focusedValue(\.将棋盤フォーカス値, _)"を呼ぶ。
}
