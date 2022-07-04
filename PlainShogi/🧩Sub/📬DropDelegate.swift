
import SwiftUI
import UniformTypeIdentifiers

struct 📬盤上ドロップ: DropDelegate {
    var 📱: 📱AppModel
    var 位置: Int
    
    func performDrop(info: DropInfo) -> Bool {
        📱.盤上のここにドロップする(位置, info)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        📱.ここはドロップ可能か確認する(位置, info)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        📱.アプリ外部からのドロップかどうかを確認する(info)
    }
    
    init(_ ⓐppModel: 📱AppModel, _ ｲﾁ: Int) {
        📱 = ⓐppModel
        位置 = ｲﾁ
    }
}


struct 📬盤外ドロップ: DropDelegate {
    var 📱: 📱AppModel
    var 陣営: 王側か玉側か
    
    func performDrop(info: DropInfo) -> Bool {
        📱.盤外にドロップする(陣営, info)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        📱.アプリ外部からのドロップかどうかを確認する(info)
    }
    
    init(_ ⓐppModel: 📱AppModel, _ ｼﾞﾝｴｲ: 王側か玉側か) {
        📱 = ⓐppModel
        陣営 = ｼﾞﾝｴｲ
    }
}
