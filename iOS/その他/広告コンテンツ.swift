import SwiftUI

struct 広告コンテンツ: View {
    @State private var targetApp: 📣ADTargetApp = .pickUpAppWithout(.PlainShogiBoard)
    var body: some View {
        📣ADView(self.targetApp, second: 20)
    }
}
