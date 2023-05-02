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
            メニュートップ()
        }
    }
}

private struct メニュートップ: View {
    var body: some View {
        NavigationStack {
            List {
                🛠OptionMenu()
                💁GuideMenu()
            }
            .navigationTitle(ℹ️appName)
        }
    }
}

private struct 💁GuideMenu: View {
    var body: some View {
        NavigationLink {
            self.メニュー()
        } label: {
            Label("About App", systemImage: "questionmark")
        }
    }
    private func メニュー() -> some View {
        List {
            ZStack {
                Color.clear
                VStack(spacing: 8) {
                    Image("RoundedIcon")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    VStack(spacing: 6) {
                        Text(ℹ️appName)
                            .font(.system(.headline))
                            .tracking(1.5)
                            .opacity(0.75)
                        Text(ℹ️appSubTitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .lineLimit(2)
                    .minimumScaleFactor(0.1)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
            }
            Link(destination: 🔗appStoreProductURL) {
                Label("Open AppStore page", systemImage: "link")
            }
        }
    }
}
