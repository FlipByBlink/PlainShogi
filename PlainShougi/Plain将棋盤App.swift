
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
                
                広告AD()
            }
            .statusBar(hidden: true)
            .sheet(isPresented: $🚩メニューを開く) {
                メニュー()
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
            .environmentObject(将棋)
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
                    Label("駒を長押しで選択してそのまま移動", systemImage: "hand.draw")
                    
                    Label("盤上の駒をダブルタップして裏返す", systemImage: "rotate.right")
                } header: {
                    Text("あそび方")
                }
                
                
                Button {
                    将棋.はじめに戻す()
                    🔙.callAsFunction()
                } label: {
                    Label("盤面を元に戻す", systemImage: "arrow.counterclockwise")
                }
                
                
                Section {
                    let 🔗 = "https://apps.apple.com/app/id1620268476"
                    Link(destination: URL(string: 🔗)!) {
                        Label("AppStore リンク", systemImage: "link")
                    }
                }

                
                Section {
                    Toggle(isOn: $English表記) {
                        Label("English表記", systemImage: "p.square")
                    }
                } header: {
                    Text("オプション")
                }
                
                
                Section {
                    Label("盤外の駒をトリプルタップして削除", systemImage: "trash")
                    
                    Label("駒を他アプリへドラッグして盤面を書き出す", systemImage: "square.and.arrow.up")
                    
                    Label("テキストをドロップして盤面を読み込む", systemImage: "square.and.arrow.down")
                } header: {
                    Text("細かな使い方")
                }
                
                
                Section {
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
