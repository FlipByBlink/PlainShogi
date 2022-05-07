
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
                メニューMenu()
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
                .accessibilityLabel("🌏メニューを開く")
            }
        }
    }
}
