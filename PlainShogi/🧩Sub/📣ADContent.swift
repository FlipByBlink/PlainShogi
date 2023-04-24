import SwiftUI

struct 📣ADContent: ViewModifier {
    @EnvironmentObject private var 🛒: 🛒StoreModel
    @State private var ⓐpp: 📣MyApp = .pickUpAppWithout(.PlainShogiBoard)
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $🛒.🚩showADSheet) {
                📣ADSheet(self.ⓐpp)
                    .environmentObject(🛒)
            }
            .onAppear {
                🛒.checkToShowADSheetOnLaunch()
            }
    }
}
