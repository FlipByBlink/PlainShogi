
import SwiftUI

enum 📁SourceFolder: String, CaseIterable, Identifiable {
    
    case main
    case 🧩Sub
    case 📄Information
    case 📣AD
    case 🛒InAppPurchase
    
    var id: String { self.rawValue }
}


struct 📓SourceCodeMenu: View {
    var body: some View {
        List {
            ForEach(📁SourceFolder.allCases) { 📁 in
                📓CodeSection(📁.rawValue)
            }
            
            📑BundleMainInfoDictionary()
            
            🔗RepositoryLink()
        }
        .navigationTitle("Source code")
    }
}


struct 📓CodeSection: View {
    var 🄳irectoryPath: String
    
    var 📁URL: URL {
        Bundle.main.bundleURL.appendingPathComponent(🄳irectoryPath)
    }
    
    var 🏷FileName: [String] {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: 📁URL.path)
        } catch {
            return []
        }
    }
    
    var body: some View {
        Section {
            ForEach(🏷FileName, id: \.self) { 🏷 in
                NavigationLink(🏷) {
                    let 📃 = try? String(contentsOf: 📁URL.appendingPathComponent(🏷))
                    📰SourceCodeView(📃 ?? "🐛Bug", 🏷)
                }
            }
            
            if 🏷FileName.isEmpty {
                Text("🐛Bug")
            }
        } header: {
            Text(🄳irectoryPath)
                .textCase(.none)
        }
    }
    
    init(_ ⓓirectoryPath: String) {
        🄳irectoryPath = ⓓirectoryPath
    }
}


let 🄱undleMainInfoDictionary = Bundle.main.infoDictionary!.description
struct 📑BundleMainInfoDictionary: View {
    var body: some View {
        Section {
            NavigationLink("Bundle.main.infoDictionary") {
                ScrollView {
                    Text(🄱undleMainInfoDictionary)
                        .padding()
                }
                .navigationBarTitle("Bundle.main.infoDictionary")
                .navigationBarTitleDisplayMode(.inline)
                .textSelection(.enabled)
            }
        }
    }
}


struct 🔗RepositoryLink: View {
    var body: some View {
        let 🔗 = "https://github.com/FlipByBlink/PlainShogi"
        Section {
            Link(destination: URL(string: 🔗)!) {
                HStack {
                    Label("Web Repository", systemImage: "link")
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.forward.app")
                }
            }
        } footer: {
            Text(🔗)
        }
        
        
        let Mirror🔗 = "https://gitlab.com/FlipByBlink/PlainShogi_Mirror"
        Section {
            Link(destination: URL(string: Mirror🔗)!) {
                HStack {
                    Label("Web Repository", systemImage: "link")
                    
                    Text("(Mirror)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.forward.app")
                }
            }
        } footer: {
            Text(Mirror🔗)
        }
    }
}


struct 📰SourceCodeView: View {
    var 🅃ext: String
    var 🅃itle: LocalizedStringKey
    
    var body: some View {
        ScrollView {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(🅃ext)
                    .padding()
            }
        }
        .navigationBarTitle(🅃itle)
        .navigationBarTitleDisplayMode(.inline)
        .font(.caption.monospaced())
        .textSelection(.enabled)
    }
    
    init(_ ⓣext: String, _ ⓣitle: String) {
        🅃ext = ⓣext
        🅃itle = LocalizedStringKey(ⓣitle)
    }
}
