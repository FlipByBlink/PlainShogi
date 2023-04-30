import SwiftUI

typealias 🛒Storeモデル = 🛒StoreModel

struct 📣広告コンテンツ: View {
    @State private var ⓐpp: 📣MyApp = .pickUpAppWithout(.PlainShogiBoard)
    var body: some View {
        📣ADView(self.ⓐpp, second: 20)
    }
}
