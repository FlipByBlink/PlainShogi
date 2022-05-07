
import SwiftUI


@main
struct Plain将棋盤App: App {
    @StateObject var 将棋 = 将棋Model()
    
    @State private var 🚩メニューを開く = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Rectangle().opacity(0)
                
                ContentView()
                    .environmentObject(将棋)
                
                広告AD()
            }
            .statusBar(hidden: true)
            .sheet(isPresented: $🚩メニューを開く) {
                メニュー()
                    .environmentObject(将棋)
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    🚩メニューを開く = true
                } label: {
                    Text("…")
                        .foregroundColor(.primary)
                        .padding(32)
                }
                .accessibilityLabel("メニュー")
            }
        }
    }
}


struct メニュー: View {
    
    @EnvironmentObject var 将棋: 将棋Model
    
    @Environment(\.dismiss) var 🔙: DismissAction
    
    @AppStorage("English表記") var English表記: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Label("駒を長押しして持ち上げ、そのままスライドさせて移動する", systemImage: "hand.draw")
                    
                    Label("盤上の駒をダブルタップして裏返す", systemImage: "rotate.right")
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
                        Label("盤外の駒をトリプルタップして削除する", systemImage: "trash")
                        
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
                            Label("AppStore リンク", systemImage: "link")
                            
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
            .navigationTitle("メニュー")
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
