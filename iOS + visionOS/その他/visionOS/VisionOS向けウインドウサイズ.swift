import SwiftUI

struct VisionOS向けウインドウサイズ: ViewModifier {
    func body(content: Content) -> some View {
#if os(visionOS)
        content.frame(minWidth: 500, minHeight: 500)
#else
        content
#endif
    }
}
