
import SwiftUI
import UniformTypeIdentifiers

//TODO: 実装方法を色々検討する
struct 📬盤上ドロップ: DropDelegate {
    var 📱: 📱AppModel
    var 位置: Int
    
    func performDrop(info: DropInfo) -> Bool {
        debugPrint(info)
        let 📦 = info.itemProviders(for: [UTType.utf8PlainText])
        debugPrint(📦)
        return 📱.駒をここにドロップする(位置, 📦)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        📱.ここはドロップ可能か確認する(info, 位置)
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
    
    //TODO: ちゃんと実装する
    func performDrop(info: DropInfo) -> Bool {
        print("Dropped 盤外")
        return true
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        📱.アプリ外部からのドロップかどうかを確認する(info)
    }
    
    init(_ ⓐppModel: 📱AppModel, _ ｼﾞﾝｴｲ: 王側か玉側か) {
        📱 = ⓐppModel
        陣営 = ｼﾞﾝｴｲ
    }
}
