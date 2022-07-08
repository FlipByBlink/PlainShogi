
import SwiftUI

struct 📄InformationMenuLink: View {
    var body: some View {
        NavigationLink {
            📄InformationMenu()
        } label: {
            Label("Information", systemImage: "doc")
        }
    }
}

struct 📄InformationMenu: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    ScrollView {
                        Text("🌏AppStoreDescription")
                            .padding()
                    }
                    .navigationBarTitle("About")
                    .navigationBarTitleDisplayMode(.inline)
                    .textSelection(.enabled)
                } label: {
                    Text("🌏AppStoreDescription")
                        .font(.subheadline)
                        .lineLimit(6)
                        .padding(8)
                        .accessibilityLabel("About")
                }
            } header: { Text("About") }
            
            
            let 🔗 = "https://apps.apple.com/app/id1620268476"
            Section {
                Link(destination: URL(string: 🔗)!) {
                    HStack {
                        Label("Open AppStore page", systemImage: "link")
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                    }
                }
            } footer: { Text(🔗) }
            
            
            Section {
                NavigationLink {
                    Text("""
                        2022-04-21
                        
                        (Japanese)
                        このアプリ自身において、ユーザーの情報を一切収集しません。
                        
                        (English)
                        This application don't collect user infomation.
                        """)
                    .padding(32)
                    .textSelection(.enabled)
                    .navigationTitle("Privacy Policy")
                } label: {
                    Label("Privacy Policy", systemImage: "person.text.rectangle")
                }
            }
            
            
            🕒VersionHistoryLink()
            📓SourceCodeLink()
            🧑‍💻AboutDeveloperPublisherLink()
        }
        .navigationTitle("Information")
    }
}
