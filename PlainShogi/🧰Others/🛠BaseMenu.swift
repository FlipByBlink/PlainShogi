
import SwiftUI

struct 🛠MenuButton: View {
    @State private var 🚩ShowMenu = false
    
    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            🚩ShowMenu = true
        } label: {
            Text("…")
                .padding(32)
        }
        .tint(.primary)
        .accessibilityLabel("Open menu")
        .sheet(isPresented: $🚩ShowMenu) {
            🛠MenuSheet()
                .onDisappear {
                    🚩ShowMenu = false
                }
        }
    }
}


struct 🛠MenuSheet: View {
    @Environment(\.dismiss) var 🔙: DismissAction
    
    var body: some View {
        NavigationView {
            List {
                🛠盤面初期化ボタン(🔙)
                
                🛠盤面整理ボタン(🔙)
                
                🛠AppMenu()
                
                
                📣ADMenu()
                
                
                📄InformationMenu()
            }
            .navigationTitle("Plain将棋盤")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        🔙.callAsFunction()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.secondary)
                            .grayscale(1.0)
                            .padding(8)
                    }
                    .accessibilityLabel("Dismiss")
                }
            }
        }
    }
}
