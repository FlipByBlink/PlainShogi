import SwiftUI

struct 将棋View: View {
    var body: some View {
        盤と手駒を配置 {
            盤外(.対面)
            盤面と段と筋()
            盤外(.手前)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(操作エリア外で駒選択を解除())
        .modifier(成駒確認アラート())
        .modifier(レイアウト.推定())
        .modifier(オプション変更アニメーション())
    }
}
