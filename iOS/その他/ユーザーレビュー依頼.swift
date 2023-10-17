import SwiftUI

struct ユーザーレビュー依頼: ViewModifier {
    @Environment(\.requestReview) var requestReview
    @AppStorage("launchCount") private var launchCount: Int = 0
    func body(content: Content) -> some View {
        content
            .task {
                self.launchCount += 1
                if [20, 50, 90].contains(self.launchCount) {
                    self.requestReview()
                }
            }
    }
}
