import SwiftUI

struct ContentView_watchOSApp: View {
    var body: some View {
        TabView {
            将棋View()
            サブタブ()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

private struct サブタブ: View {
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

enum 🪧シートカテゴリ: Identifiable, Hashable {
    case メニュー, 履歴, ブックマーク, 手駒編集(王側か玉側か), SharePlayガイド, 広告
    var id: Self { self }
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
