
import SwiftUI


struct SourceCodeView: View {
    
    let 📲URL = Bundle.main.bundleURL
    
    let 💾 = FileManager.default
    
    var 📁Primary: URL {
        📲URL.appendingPathComponent("📁Primary")
    }
    
    var 📑Primary: [String] {
        try! 💾.contentsOfDirectory(atPath: 📁Primary.path)
    }
    
    var 📁Secondary: URL {
        📲URL.appendingPathComponent("📁Secondary")
    }
    
    var 📑Secondary: [String] {
        try! 💾.contentsOfDirectory(atPath: 📁Secondary.path)
    }
    
    @Environment(\.dismiss) var 🔙: DismissAction
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(📑Primary, id: \.self) { 📃 in
                        NavigationLink(📃) {
                            let 📍 = 📁Primary.appendingPathComponent(📃)
                            
                            ScrollView(.vertical) {
                                ScrollView(.horizontal) {
                                    Text(try! String(contentsOf: 📍))
                                        .font(.caption.monospaced())
                                        .padding()
                                }
                            }
                            .navigationBarTitle(📃)
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }
                
                Section {
                    ForEach(📑Secondary, id: \.self) { 📃 in
                        NavigationLink(📃) {
                            let 📍 = 📁Secondary.appendingPathComponent(📃)
                            
                            ScrollView(.vertical) {
                                ScrollView(.horizontal) {
                                    Text(try! String(contentsOf: 📍))
                                        .font(.caption.monospaced())
                                        .padding()
                                }
                            }
                            .navigationBarTitle(📃)
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }
                
                Section {
                    NavigationLink("Bundle.main.infoDictionary") {
                        ScrollView {
                            Text(Bundle.main.infoDictionary!.description)
                                .font(.caption.monospaced())
                                .padding()
                        }
                    }
                }
                
                let 🔗 = URL(string: "https://github.com/FlipByBlink/PlainShougi")!
                Section {
                    Link(destination: 🔗) {
                        Label("Web Repository link", systemImage: "link")
                    }
                } footer: {
                    Text(🔗.description)
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




struct SourceCodeView_Previews: PreviewProvider {
    static var previews: some View {
        SourceCodeView()
    }
}
