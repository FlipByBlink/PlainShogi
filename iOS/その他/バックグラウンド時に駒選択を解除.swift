import SwiftUI

struct バックグラウンド時に駒選択を解除: ViewModifier {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.scenePhase) var scenePhase
    func body(content: Content) -> some View {
        content
            .onChange(of: self.scenePhase) {
                if $0 == .background { モデル.駒の選択を解除する() }
            }
    }
}
