
import SwiftUI

struct 🛠MenuSheet: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    @Environment(\.dismiss) var 🔙: DismissAction
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Label("長押しで駒を持ち上げ、そのままスライドさせて移動する", systemImage: "hand.draw")
                        .padding(.vertical, 8)
                    
                    Label("ダブルタップで盤上の駒を裏返す", systemImage: "rotate.right")
                        .padding(.vertical, 8)
                } header: {
                    Text("How to")
                }
                .foregroundStyle(.primary)
                
                
                Button {
                    📱.はじめに戻す()
                    🔙.callAsFunction()
                } label: {
                    Label("盤面を元に戻す", systemImage: "arrow.counterclockwise")
                }
                
                
                Section {
                    Toggle(isOn: 📱.$🚩En表記) {
                        Label("English表記に変更する", systemImage: "p.square")
                    }
                } header: {
                    Text("Option")
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
                    Text(📱.テキストに変換する())
                        .padding()
                        .accessibilityLabel("Plain text")
                        .textSelection(.enabled)
                } header: {
                    Text("テキスト書き出し例")
                }
                
                
                📣ADMenu()
                
                
                📄InformationMenu()
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
                    .accessibilityLabel("Dismiss")
                }
            }
        }
    }
}
