import SwiftUI
import GroupActivities

struct ユーザーレビュー依頼: ViewModifier {
    @Environment(\.requestReview) var requestReview
    @AppStorage("launchCount") private var launchCount: Int = 0
    @StateObject private var groupStateObserver = GroupStateObserver()
    func body(content: Content) -> some View {
        content
            .task {
                try? await Task.sleep(for: .seconds(10))
                self.launchCount += 1
                if [20, 50, 90].contains(self.launchCount),
                   !self.groupStateObserver.isEligibleForGroupSession {
                    self.requestReview()
                }
            }
    }
}
