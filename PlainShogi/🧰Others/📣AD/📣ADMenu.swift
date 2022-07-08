
import SwiftUI
import StoreKit

struct 📣ADMenuLink: View {
    @EnvironmentObject var 🛒: 🛒StoreModel
    
    var body: some View {
        Section {
            if 🛒.🚩Purchased == false { 📣ADView() }
            
            NavigationLink {
                📣ADMenu()
            } label: {
                Label("About AD", systemImage: "megaphone")
            }
        }
    }
}

struct 📣ADMenu: View {
    @EnvironmentObject var 🛒: 🛒StoreModel
    
    var body: some View {
        List {
            Section {
                Text("🌏ADDescription") //Localizable.strings
                    .padding()
            } header: { Text("About") }
            
            🛒PurchaseSection()
            
            Section {
                ForEach(📣AppName.allCases) { 🏷 in
                    📣ADView(🏷)
                }
            }
        }
        .navigationTitle("About AD")
    }
}
