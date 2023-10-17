import SwiftUI

struct オプション変更アニメーション: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @AppStorage("セリフ体") var セリフ体: Bool = false
    @AppStorage("太字") var 太字: Bool = false
    @AppStorage("サイズ") var サイズ: 字体.サイズ = .標準
    func body(content: Content) -> some View {
        content
            .animation(.default, value: モデル.english表記)
            .animation(.default, value: モデル.上下反転)
            .animation(.default, value: モデル.増減モード中)
            .animation(.default, value: self.セリフ体)
            .animation(.default, value: self.太字)
            .animation(.default, value: self.サイズ)
    }
}
