import SwiftUI

struct シート管理: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .sheet(item: $モデル.表示中のシート) {
                switch $0 {
                    case .メニュー: メニューコンテンツ()
                    case .手駒増減(let 陣営): 手駒増減メニュー(陣営)
                    default: Text(verbatim: "⚠︎")
                }
            }
    }
}
