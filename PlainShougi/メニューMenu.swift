
import SwiftUI


struct メニューMenu: View {
    
    @EnvironmentObject var 将棋: 将棋Model
    
    @Environment(\.dismiss) var 🔙: DismissAction
    
    @AppStorage("English表記") var English表記: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Label("長押しで駒を持ち上げ、そのままスライドさせて移動する", systemImage: "hand.draw")
                        .padding(.vertical, 8)
                    
                    Label("ダブルタップで盤上の駒を裏返す", systemImage: "rotate.right")
                        .padding(.vertical, 8)
                } header: {
                    Text("あそび方")
                }
                .foregroundStyle(.primary)
                
                
                Button {
                    将棋.はじめに戻す()
                    🔙.callAsFunction()
                } label: {
                    Label("盤面を元に戻す", systemImage: "arrow.counterclockwise")
                }
                
                
                Section {
                    Toggle(isOn: $English表記) {
                        Label("English表記に変更する", systemImage: "p.square")
                    }
                } header: {
                    Text("オプション")
                }
                
                
                Section {
                    Group {
                        Label("トリプルタップで盤外の駒を削除する", systemImage: "trash")
                        
                        Label("駒を他のアプリへドラッグして盤面をテキストとして書き出す", systemImage: "square.and.arrow.up")
                        
                        Label("他のアプリからテキストを盤上にドロップして盤面を読み込む", systemImage: "square.and.arrow.down")
                    }
                    .foregroundStyle(.secondary)
                } header: {
                    Text("細かな使い方")
                }
                
                
                Section {
                    let 🔗 = "https://apps.apple.com/app/id1620268476"
                    Link(destination: URL(string: 🔗)!) {
                        HStack {
                            Label("AppStoreのアプリページを開く", systemImage: "link")
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.forward.app")
                        }
                    }
                    
                    NavigationLink {
                        Text("📄TextAboutAD")
                            .padding()
                            .navigationTitle("About self-AD")
                    } label: {
                        Label("アプリ内広告について", systemImage: "exclamationmark.bubble")
                    }
                    
                    NavigationLink {
                        ソース確認SourceCheck()
                    } label: {
                        Label("ソースコードを確認する", systemImage: "doc.plaintext")
                    }
                }
                
                
                Section {
                    Text(将棋.テキストに変換する())
                        .padding()
                        .textSelection(.enabled)
                } header: {
                    Text("テキスト書き出し例")
                }
            }
            .navigationTitle("Plain将棋盤")
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




struct メニューMenu_Previews: PreviewProvider {
    static var previews: some View {
        メニューMenu()
    }
}
