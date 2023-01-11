import SwiftUI

@main
struct Plain将棋盤App: App {
    @StateObject var 📱 = 📱アプリモデル()
    @StateObject var 🛒 = 🛒Storeモデル()
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                ContentView()
                SharePlayインジケーター()
            }
            .overlay(alignment: .bottomTrailing) { 🛠メニューボタン() }
            .sheet(isPresented: $📱.🚩メニューを表示) { 🛠アプリメニュー() }
            .modifier(初回起動時に駒の動かし方の説明アラート())
            .overlay(alignment: .bottom) { 📣広告バナー() }
            .task { UIApplication.shared.isIdleTimerDisabled = true }
            .modifier(SharePlay環境構築())
            .environmentObject(📱)
            .environmentObject(🛒)
        }
    }
}

struct プレースホルダーView: View {
    var body: some View {
        Image(systemName: "rectangle.dashed")
            .resizable()
            .frame(width: 200, height: 120)
            .foregroundStyle(.tertiary)
    }
}



typealias 🛒Storeモデル = 🛒StoreModel
typealias 📣広告バナー = 📣ADBanner
