import SwiftUI

struct ツールボタン: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Group {
                    if モデル.増減モード中 {
                        増減モード完了ボタン()
                    } else {
                        HStack {
                            共有ボタン()
                            メニューボタン()
                        }
                    }
                }
                .animation(.default, value: モデル.増減モード中)
            }
    }
}
