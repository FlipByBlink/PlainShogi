import SwiftUI

struct ツールボタンズ: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Group {
                    if モデル.増減モード中 {
                        増減モード完了ボタン()
                    } else {
                        メニューボタン()
                    }
                }
                .animation(.default, value: モデル.増減モード中)
            }
    }
}
