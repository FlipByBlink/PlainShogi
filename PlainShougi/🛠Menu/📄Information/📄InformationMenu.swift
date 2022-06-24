
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
                        .redacted(reason: .placeholder)
                    } label: {
                        Text(📄AppDescription)
                            .font(.subheadline)
                            .lineLimit(4)
                            .padding(8)
                            .redacted(reason: .placeholder)
                    }
                } header: {
                    Text("About")
                }
                
                
                🏷VersionSection()
                
                
                let 🔗 = "https://apps.apple.com/app/id1111" //FIXME: AppStore URL
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
                            2022-AA-AA
                            
                            (English)This application don't collect user infomation.
                            
                            (Japanese)このアプリ自身において、ユーザーの情報を一切収集しません。
                            """) //FIXME: Privacy Policy
                        .padding(32)
                        .textSelection(.enabled)
                        .navigationTitle("Privacy Policy")
                    } label: {
                        Label("Privacy Policy", systemImage: "person.text.rectangle")
                    }
                }
                
                
                // Transparency Report section ?
                // - Background
                // - Bussiness model
                
                
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
