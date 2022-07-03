
import SwiftUI
import UniformTypeIdentifiers

//TODO: 実装方法を色々検討する
//TODO: 「アプリ外からのドロップか判定」をDelegate内で実装する
struct 📬盤上DropDelegate: DropDelegate {
    var 📱: 📱AppModel
    var 位置: Int
    
    func performDrop(info: DropInfo) -> Bool {
        debugPrint(info)
        let 📦 = info.itemProviders(for: [UTType.utf8PlainText])
        debugPrint(📦)
        return 📱.駒をここにドロップする(位置, 📦)
    }
    
    //FIXME: アプリ外からドロップする際に適切に動作しない
    func dropUpdated(info: DropInfo) -> DropProposal? {
        if 📱.現状 == .アプリ外部からドラッグしている {
            return nil
        }
        
        if 位置 == 📱.ドラッグした盤上の駒の元々の位置 {
            return DropProposal(operation: .cancel)
        }
        
        if let 元々の位置 = 📱.ドラッグした盤上の駒の元々の位置 {
            if 📱.駒の配置[位置]?.陣営 == 📱.駒の配置[元々の位置]?.陣営 {
                return DropProposal(operation: .cancel)
            }
        }
        
        return nil
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        let 📦 = info.itemProviders(for: [UTType.utf8PlainText])
        📱.アプリ外部からのドロップかどうかを確認する(📦)
        if 📦.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    init(_ model: 📱AppModel, _ ｲﾁ: Int) {
        📱 = model
        位置 = ｲﾁ
    }
}


struct 📬盤外DropDelegate: DropDelegate {
    var 📱: 📱AppModel
    var 陣営: 王側か玉側か
    
    func performDrop(info: DropInfo) -> Bool {
        print("Dropped 盤外")
        return true
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        let 📦 = info.itemProviders(for: [UTType.utf8PlainText])
        📱.アプリ外部からのドロップかどうかを確認する(📦)
        if 📦.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    init(_ model: 📱AppModel, _ ｼﾞﾝｴｲ: 王側か玉側か) {
        📱 = model
        陣営 = ｼﾞﾝｴｲ
    }
}
