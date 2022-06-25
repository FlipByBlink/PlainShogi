
import SwiftUI

struct 📄InformationMenu: View {
    var body: some View {
        NavigationLink {
            List {
                Section {
                    NavigationLink {
                        ScrollView {
                            Text(📄AppDescription)
                                .padding()
                        }
                        .navigationBarTitle("About")
                        .navigationBarTitleDisplayMode(.inline)
                        .textSelection(.enabled)
                    } label: {
                        Text(📄AppDescription)
                            .font(.subheadline)
                            .lineLimit(6)
                            .padding(8)
                            .accessibilityLabel("About")
                    }
                } header: {
                    Text("About")
                }
                
                
                🏷VersionSection()
                
                
                let 🔗 = "https://apps.apple.com/app/id1620268476"
                Section {
                    Link(destination: URL(string: 🔗)!) {
                        HStack {
                            Label("Open AppStore page", systemImage: "link")
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.forward.app")
                        }
                    }
                } footer: {
                    Text(🔗)
                        .textSelection(.enabled)
                }
                
                
                Section {
                    NavigationLink {
                        Text("""
                            2022-04-21
                            
                            ### Japanese
                            このアプリ自身において、ユーザーの情報を一切収集しません。
                            
                            ### English
                            This application don't collect user infomation.
                            """)
                        .padding(32)
                        .textSelection(.enabled)
                        .navigationTitle("Privacy Policy")
                    } label: {
                        Label("Privacy Policy", systemImage: "person.text.rectangle")
                    }
                }
                
                
                NavigationLink {
                    📓SourceCodeMenu()
                } label: {
                    Label("Source code", systemImage: "doc.plaintext")
                }
            }
            .navigationTitle("Information")
        } label: {
            Label("Information", systemImage: "doc")
        }
    }
}
