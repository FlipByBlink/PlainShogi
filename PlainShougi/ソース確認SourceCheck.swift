
import SwiftUI


struct ソース確認SourceCheck: View {
    
    @Environment(\.dismiss) var 🔙: DismissAction
    
    var body: some View {
        List {
            📑Section("📁Primary")
            
            📑Section("📁Secondary")
            
            📑LocalizableSection()
            
            Section {
                NavigationLink("Bundle.main.infoDictionary") {
                    ScrollView {
                        📄View(Bundle.main.infoDictionary!.description)
                    }
                }
            }
            
            let 🔗 = "https://github.com/FlipByBlink/PlainShougi"
            Section {
                Link(destination: URL(string: 🔗)!) {
                    HStack {
                        Label("Web Repository link", systemImage: "link")
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.forward.app")
                    }
                }
            } footer: {
                Text(🔗)
            }
        }
        .navigationTitle("Source code")
    }
}


struct 📑Section: View {
    
    var ⓓirPath: String
    
    var 📁URL: URL {
        Bundle.main.bundleURL.appendingPathComponent(ⓓirPath)
    }
    
    var 📦: [String] {
        try! FileManager.default.contentsOfDirectory(atPath: 📁URL.path)
    }
    
    var body: some View {
        Section {
            ForEach(📦, id: \.self) { 📃 in
                NavigationLink(📃) {
                    let 📍 = 📁URL.appendingPathComponent(📃)
                    
                    ScrollView(.vertical) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            📄View(try! String(contentsOf: 📍))
                        }
                    }
                    .navigationBarTitle(📃)
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    init(_ ⓓirPath: String) {
        self.ⓓirPath = ⓓirPath
    }
}


struct 📑LocalizableSection: View {
    
    var 📁URL: URL {
        Bundle.main.bundleURL.appendingPathComponent("📁Localizable")
    }
    
    var 📦: [String] {
        ["ja.lproj/Localizable.strings", "en.lproj/Localizable.strings"]
    }
    
    var body: some View {
        Section {
            ForEach(📦, id: \.self) { 📃 in
                NavigationLink(📃) {
                    let 📍 = 📁URL.appendingPathComponent(📃)
                    
                    ScrollView(.vertical) {
                        📄View(try! String(contentsOf: 📍))
                    }
                    .navigationBarTitle(📃)
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}


struct 📄View: View {
    
    var 📄: String
    
    var body: some View {
        Text(📄)
            .font(.caption.monospaced())
            .padding()
    }
    
    init(_ 📄: String) {
        self.📄 = 📄
    }
}








struct ソース確認SourceCheck_Previews: PreviewProvider {
    static var previews: some View {
        ソース確認SourceCheck()
    }
}
