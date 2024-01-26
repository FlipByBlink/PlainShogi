import SwiftUI

struct ドロップデリゲート: DropDelegate {
    private var モデル: アプリモデル
    private var 移動先: 駒の移動先パターン
    
    func performDrop(info: DropInfo) -> Bool {
        モデル.ここにドロップする(self.移動先, info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        モデル.ここはドロップ可能か確認する(self.移動先)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        モデル.有効なドロップかチェックする(info)
    }
    
    init(_ ﾓﾃﾞﾙ: アプリモデル, _ ｲﾄﾞｳｻｷ: 駒の移動先パターン) {
        (モデル, self.移動先) = (ﾓﾃﾞﾙ, ｲﾄﾞｳｻｷ)
    }
}
