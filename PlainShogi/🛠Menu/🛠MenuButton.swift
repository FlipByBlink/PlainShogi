
import SwiftUI

struct 🛠MenuButton: View {
    @State private var 🚩ShowMenu = false
    
    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            🚩ShowMenu = true
        } label: {
            Text("…")
                .foregroundColor(.primary)
                .padding(32)
        }
        .accessibilityLabel("Open menu")
        .sheet(isPresented: $🚩ShowMenu) {
            🛠MenuSheet()
                .onDisappear {
                    🚩ShowMenu = false
                }
        }
    }
}
