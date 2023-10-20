import SwiftUI

struct オプション変更アニメーション: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .animation(.default, value: モデル.english表記)
            .animation(.default, value: モデル.上下反転)
            .animation(.default, value: モデル.増減モード中)
            .animation(.default, value: モデル.セリフ体)
            .animation(.default, value: モデル.太字)
            .animation(.default, value: モデル.サイズ)
    }
}
