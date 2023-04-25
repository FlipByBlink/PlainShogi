import SwiftUI

struct 📬DropDelegate: DropDelegate {
    private var 📱: 📱アプリモデル
    private var 移動先: 駒の移動先パターン
    
    func performDrop(info: DropInfo) -> Bool {
        📱.ここにドロップする(self.移動先, info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        📱.ここはドロップ可能か確認する(self.移動先)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        📱.有効なドロップかチェックする(info)
    }
    
    init(_ ﾓﾃﾞﾙ: 📱アプリモデル, _ ｲﾄﾞｳｻｷ: 駒の移動先パターン) {
        (📱, self.移動先) = (ﾓﾃﾞﾙ, ｲﾄﾞｳｻｷ)
    }
}
