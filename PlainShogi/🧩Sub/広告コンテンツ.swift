import SwiftUI

typealias アプリ内課金モデル = 🛒StoreModel

struct 広告コンテンツ: View {
    @State private var targetApp: 📣MyApp = .pickUpAppWithout(.PlainShogiBoard)
    var body: some View {
        📣ADView(self.targetApp, second: 20)
    }
}
