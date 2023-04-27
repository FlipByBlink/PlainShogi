import SwiftUI

typealias 🛒Storeモデル = 🛒StoreModel

struct 📣広告コンテンツ: ViewModifier {
    @EnvironmentObject private var 🛒: 🛒StoreModel
    @State private var ⓐpp: 📣MyApp = .pickUpAppWithout(.PlainShogiBoard)
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $🛒.🚩showADSheet) {
                📣ADView(self.ⓐpp, second: 15)
                    .environmentObject(🛒)
            }
            .onAppear {
                🛒.checkToShowADSheet()
            }
    }
}
