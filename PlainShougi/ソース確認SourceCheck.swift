
import SwiftUI


struct SourceCodeView: View {
    
    @Environment(\.dismiss) var 🔙: DismissAction
    
    var body: some View {
        NavigationView {
            List {
                📑Section("Primary")
                
                📑Section("Secondary")
                
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
                        Label("Web Repository link", systemImage: "link")
                    }
                } footer: {
                    Text(🔗)
                }
            }
            .navigationTitle("Source code")
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
                }
            }
        }
    }
}


struct 📑Section: View {
    
    var ⓓirPath: String
    
    var 📁URL: URL {
        Bundle.main.bundleURL.appendingPathComponent("📁" + ⓓirPath)
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
                        ScrollView(.horizontal) {
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




struct SourceCodeView_Previews: PreviewProvider {
    static var previews: some View {
        SourceCodeView()
    }
}
