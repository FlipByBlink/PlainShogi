import SwiftUI

struct VisionOS向けHoverEffect: ViewModifier {
    var 条件: Bool
    func body(content: Content) -> some View {
#if os(visionOS)
        content
            .hoverEffect(isEnabled: self.条件)
#else
        content
#endif
    }
    init(_ 条件: Bool = true) {
        self.条件 = 条件
    }
}
