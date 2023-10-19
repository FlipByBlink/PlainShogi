import SwiftUI

struct ツールボタン: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                HStack {
                    if !モデル.増減モード中 { 共有ボタン() }
                        
                    Spacer()
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
