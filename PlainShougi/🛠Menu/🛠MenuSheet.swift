
import SwiftUI

struct 🛠MenuSheet: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    @AppStorage("placeholder") var 🚩placeholder: Bool = false
    
    @Environment(\.dismiss) var 🔙: DismissAction
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("    placeholder    ", isOn: $🚩placeholder)
                        .redacted(reason: .placeholder)
                } header: {
                    Text("Option")
                }
                
                
                📣ADMenu()
                
                
                📄InformationMenu()
            }
            .navigationTitle("AppName") //FIXME: App DisplayName
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
