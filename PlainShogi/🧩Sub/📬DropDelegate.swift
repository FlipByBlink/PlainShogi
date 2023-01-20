import SwiftUI
import UniformTypeIdentifiers

struct 📬盤上ドロップ: DropDelegate {
    private var 📱: 📱アプリモデル
    private var 位置: Int
    
    func performDrop(info: DropInfo) -> Bool {
        📱.盤上のここにドロップする(self.位置, info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        📱.盤上のここはドロップ可能か確認する(self.位置)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        📱.有効なドロップかチェックする(info)
    }
    
    init(_ ﾓﾃﾞﾙ: 📱アプリモデル, _ ｲﾁ: Int) {
        (📱, self.位置) = (ﾓﾃﾞﾙ, ｲﾁ)
    }
}

struct 📬盤外ドロップ: DropDelegate {
    private var 📱: 📱アプリモデル
    private var 陣営: 王側か玉側か
    
    func performDrop(info: DropInfo) -> Bool {
        📱.盤外のこちら側にドロップする(self.陣営, info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        📱.盤外のここはドロップ可能か確認する(self.陣営)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        📱.有効なドロップかチェックする(info)
    }
    
    init(_ ﾓﾃﾞﾙ: 📱アプリモデル, _ ｼﾞﾝｴｲ: 王側か玉側か) {
        (📱, self.陣営) = (ﾓﾃﾞﾙ, ｼﾞﾝｴｲ)
    }
}
