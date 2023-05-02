import SwiftUI

struct ContentView_watchOSApp: View {
    var body: some View {
        将棋View_watchOSApp()
    }
}

struct メニューボタン: View { // ⚙️
    @Environment(\.マスの大きさ) private var マスの大きさ
    @State private var シートを表示: Bool = false
    var body: some View {
        Button {
            self.シートを表示 = true
            💥フィードバック.軽め()
        } label: {
            Image(systemName: "gearshape")
                .resizable()
                .frame(width: self.マスの大きさ * 0.75,
                       height: self.マスの大きさ * 0.75)
                .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: self.$シートを表示) {
            🛠メニュートップ()
        }
    }
}
