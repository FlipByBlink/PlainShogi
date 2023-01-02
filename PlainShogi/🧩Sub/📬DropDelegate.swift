import SwiftUI
import UniformTypeIdentifiers

struct 📬盤上ドロップ: DropDelegate {
    var 📱: 📱AppModel
    var 位置: Int
    @Binding var 🚩成り駒ダイアログを表示: Bool
    
    func performDrop(info: DropInfo) -> Bool {
        let 状態 = 📱.現状
        let ⓡesult = 📱.盤上のここにドロップする(self.位置, info)
        if ⓡesult {
            if 状態 == .盤上の駒をドラッグしている {
                if 📱.この駒は成れる(位置) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        self.🚩成り駒ダイアログを表示 = true
                    }
                }
            }
        }
        return ⓡesult
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        📱.盤上のここはドロップ可能か確認する(self.位置)
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        📱.有効なドロップかチェックする(info)
    }
    
    init(_ ⓐppModel: 📱AppModel, _ ｲﾁ: Int, _ 成り駒ダイアログを表示: Binding<Bool>) {
        (📱, self.位置, self._🚩成り駒ダイアログを表示) = (ⓐppModel, ｲﾁ, 成り駒ダイアログを表示)
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
