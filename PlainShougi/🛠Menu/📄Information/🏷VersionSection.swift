
import SwiftUI

struct 🏷VersionSection: View {
    var body: some View {
        Section {
            NavigationLink {
                ScrollView {
                    Text(🕒VersionHistory)
                        .padding()
                }
                .navigationBarTitle("Version History")
                .navigationBarTitleDisplayMode(.inline)
                .textSelection(.enabled)
            } label: {
                Label(🕒LatestVersionNumber, systemImage: "signpost.left")
            }
            .accessibilityLabel("Version History")
        } header: {
            Text("Version")
        } footer: {
            let 📅 = Date.now.formatted(date: .numeric, time: .omitted)
            Text("builded on \(📅)")
        }
    }
}


let 🕒LatestVersionNumber = "1.1"

let 🕒LatestVersionDescription = """
==== English ====
- AAAA
==== Japanese(native) ====
- AAAA
"""

var 🕒VersionHistory: String {
    var 📃 = "🕒 Version " + 🕒LatestVersionNumber + " : "
    📃 += "(builded on " + Date.now.formatted(date: .numeric, time: .omitted) + ")\n"
    📃 += 🕒LatestVersionDescription + "\n\n\n"
    📃 += 🕒PastVersionHistory
    return 📃
}

let 🕒PastVersionHistory = """
🕒 Version 1.0 : 2022-AA-AA
Initial release
"""
