import SwiftUI

typealias アプリ内課金モデル = 🛒InAppPurchaseModel

struct アプリ内課金ハンドラー: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject var アプリ内課金: アプリ内課金モデル = .init(id: "PlainShogi.adfree")
    func body(content: Content) -> some View {
        content
            .environmentObject(self.アプリ内課金)
            .onAppear {
                if self.アプリ内課金.checkToShowADSheet() { モデル.表示中のシート = .広告 }
            }
    }
}
