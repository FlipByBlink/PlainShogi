import SwiftUI
import GroupActivities

typealias アプリ内課金モデル = 🛒InAppPurchaseModel

struct アプリ内課金ハンドラー: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @StateObject var アプリ内課金: アプリ内課金モデル = .init(id: "PlainShogi.adfree")
    @StateObject private var groupStateObserver = GroupStateObserver()
    func body(content: Content) -> some View {
        content
            .environmentObject(self.アプリ内課金)
            .task {
                if self.アプリ内課金.checkToShowADSheet(),
                   !self.groupStateObserver.isEligibleForGroupSession {
                    モデル.表示中のシート = .広告
                }
            }
    }
}
