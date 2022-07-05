
import SwiftUI

struct 🛠MenuButton: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var body: some View {
        Menu {
            🛠盤面初期化ボタン()
            🛠盤面整理ボタン()
        } label: {
            Text("…")
                .padding()
        } primaryAction: {
            📱.🚩メニューを表示 = true
            振動フィードバック()
        }
        .disabled(📱.駒を整理中)
        .padding()
        .tint(.primary)
        .accessibilityLabel("Open menu")
        .sheet(isPresented: $📱.🚩メニューを表示) {
            🛠MenuSheet()
                .onDisappear {
                    📱.🚩メニューを表示 = false
                }
        }
    }
}


struct 🛠AppMenu: View {
    @EnvironmentObject var 📱: 📱AppModel
    
    var body: some View {
        🛠盤面初期化ボタン()
        
        🛠盤面整理ボタン()
        
        Section {
            Label("長押しで駒を持ち上げ、そのままスライドさせて移動する", systemImage: "hand.draw")
                .padding(.vertical, 8)
            
            Label("ダブルタップで盤上の駒を裏返す", systemImage: "rotate.right")
                .padding(.vertical, 8)
        } header: {
            Text("あそび方")
        }
        .foregroundStyle(.primary)
        
        
        Section {
            Toggle(isOn: 📱.$🚩English表記) {
                Label("English表記に変更する", systemImage: "p.square")
            }
            
            Toggle(isOn: 📱.$🚩移動直後の駒を目立たせる) {
                Label("移動直後の駒を目立たせる", systemImage: "exclamationmark.square")
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
            Text(📱.現在の盤面をテキストに変換する())
                .padding()
                .accessibilityLabel("Plain text")
                .textSelection(.enabled)
        } header: {
            Text("テキスト書き出し例")
        }
    }
}
