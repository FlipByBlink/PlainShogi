
import SwiftUI


@main
struct Plain将棋盤App: App {
    @StateObject var 将棋 = 将棋Model()
    
    @AppStorage("English表記") var English表記: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Rectangle().opacity(0)
                
                ContentView()
                    .environmentObject(将棋)
                
                広告AD()
            }
            .statusBar(hidden: true)
            .overlay(alignment: .bottomTrailing) {
                Menu {
                    let 🔗 = "https://apps.apple.com/app/id1620268476"
                    
                    Link(destination: URL(string: 🔗)!) {
                        Label("AppStore リンク", systemImage: "link")
                    }
                    
                    Menu {
                        Toggle(isOn: $English表記) {
                            Label("English term", systemImage: "p.square")
                        }
                        
                        Label("盤外の駒をトリプルタップして削除", systemImage: "trash")
                    } label: {
                        Label("その他", systemImage: "gear")
                    }
                    
                    Button {
                        将棋.はじめに戻す()
                    } label: {
                        Label("はじめに戻す", systemImage: "arrow.counterclockwise")
                    }
                    
                    Label("盤上の駒をダブルタップして裏返す", systemImage: "rotate.right")
                    
                    Label("駒を長押しで選択してそのまま移動", systemImage: "hand.draw")
                    
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
