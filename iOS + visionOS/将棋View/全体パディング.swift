import SwiftUI

struct 全体パディング: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let 縦パディングサイズ: CGFloat = proxy.size.height > 1000 ? 24 : 16
            let 横パディングサイズ: CGFloat = proxy.size.width > 1000 ? 24 : 16
            
            content
                .modifier(Self.トップパディング(サイズ: 縦パディングサイズ))
                .padding(.bottom, 縦パディングサイズ)
                .padding(.horizontal, 横パディングサイズ)
        }
    }
}

private extension 全体パディング {
    struct トップパディング: ViewModifier {
        var サイズ: CGFloat
        func body(content: Content) -> some View {
            if #available(anyAppleOS 27.1, *) {
                content.modifier(Self.Duo向け(サイズ: self.サイズ))
            } else {
                content.padding(.top, 16)
            }
        }
        
        @available(iOS 27.1, *)
        struct Duo向け: ViewModifier {
            var サイズ: CGFloat
            @Environment(\.toolbarVerticalEdge) var toolbarVerticalEdge
            func body(content: Content) -> some View {
                content
                    .padding(.top, self.toolbarVerticalEdge != nil ? self.サイズ : 0)
            }
        }
    }
}
