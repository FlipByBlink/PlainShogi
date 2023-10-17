import SwiftUI

struct 操作エリア外で駒選択を解除: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .background {
                Color(uiColor: .systemBackground)
                    .onTapGesture { モデル.駒の選択を解除する() }
            }
    }
}
