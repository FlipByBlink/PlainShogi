import SwiftUI

struct VisionOS向けウインドウサイズ: ViewModifier {
    func body(content: Content) -> some View {
        content
#if os(visionOS)
            .frame(minWidth: 500, minHeight: 500)
#endif
    }
}
