import SwiftUI
import UniformTypeIdentifiers

struct 📬盤上ドロップ: DropDelegate {
    var 📱: 📱AppModel
    var 位置: Int
    
    func performDrop(info: DropInfo) -> Bool {
        📱.盤上のここにドロップする(self.位置, info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        📱.盤上のここはドロップ可能か確認する(self.位置)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        📱.有効なドロップかチェックする(info)
    }
    
    init(_ ⓐppModel: 📱AppModel, _ ｲﾁ: Int) {
        (📱, self.位置) = (ⓐppModel, ｲﾁ)
    }
}

struct 📬盤外ドロップ: DropDelegate {
    var 📱: 📱AppModel
    var 陣営: 王側か玉側か
    
    func performDrop(info: DropInfo) -> Bool {
        📱.盤外のこちら側にドロップする(self.陣営, info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        📱.盤外のここはドロップ可能か確認する(self.陣営)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        📱.有効なドロップかチェックする(info)
    }
    
    init(_ ⓐppModel: 📱AppModel, _ ｼﾞﾝｴｲ: 王側か玉側か) {
        (📱, self.陣営) = (ⓐppModel, ｼﾞﾝｴｲ)
    }
}
