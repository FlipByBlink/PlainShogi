
import SwiftUI


@main
struct PlainShougiApp: App {
    @StateObject var 配置 = 配置Model()
    
    @AppStorage("枠を非表示") var 枠を非表示: Bool = false
    
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Rectangle().opacity(0)
                
                ContentView()
                    .environmentObject(配置)
            }
            .statusBar(hidden: true)
            .overlay(alignment: .bottomTrailing) {
                Menu {
                    let 🔗 = "https://apps.apple.com/jp/developer/id1347562710"
                    Link(destination: URL(string: 🔗)!) {
                        Label("AppStore リンク", systemImage: "link")
                    }
                    
                    Button {
                        配置.はじめに戻す()
                    } label: {
                        Label("はじめに戻す", systemImage: "arrow.counterclockwise")
                    }
                    
                    Toggle(isOn: $枠を非表示) {
                        Label("枠を非表示", systemImage: "square.dashed")
                    }
                    
                    Label("盤外の駒をトリプルタップして削除", systemImage: "trash")
                    
                    Label("盤上の駒をダブルタップして裏返す", systemImage: "rotate.right")
                    
                    Label("駒を長押しで選択してそのまま移動", systemImage: "hand.draw")
                    
                } label: {
                    Text("…")
                        .foregroundColor(.primary)
                        .padding()
                }
                .padding()
                .accessibilityLabel("メニュー")
            }
        }
    }
}
