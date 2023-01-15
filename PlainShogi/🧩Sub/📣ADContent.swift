import SwiftUI

struct 📣ADContent: ViewModifier {
    @EnvironmentObject var 🛒: 🛒StoreModel
    @State private var ⓐpp: 📣MyApp = .pickUpAppWithout(.Plain将棋盤)
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $🛒.🚩showADSheet) {
                📣ADSheet(self.ⓐpp)
            }
            .onAppear {
                if 🛒.🚩adIsActive {
                    🛒.🚩showADSheet = true
                }
            }
    }
}
