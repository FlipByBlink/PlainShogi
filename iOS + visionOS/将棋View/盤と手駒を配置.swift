import SwiftUI

struct 盤と手駒を配置<Content: View>: View {
    @Environment(\.縦並び) var 縦並び
    @ViewBuilder var content: () -> Content
    var body: some View {
        if self.縦並び {
            VStack(spacing: レイアウト.盤と手駒の隙間) { self.content() }
        } else {
            HStack(spacing: レイアウト.盤と手駒の隙間) { self.content() }
        }
    }
}
