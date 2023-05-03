import SwiftUI

struct 🪧シートビュー: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @EnvironmentObject private var 🛒: 🛒Storeモデル
    func body(content: Content) -> some View {
        content
            .sheet(item: $📱.シートを表示) { カテゴリ in
                if case .広告 = カテゴリ {
                    📣広告コンテンツ()
                        .environmentObject(🛒)
                } else {
                    NavigationView {
                        Group {
                            switch カテゴリ {
                                case .メニュー: 🛠アプリメニュー()
                                case .履歴: 📜履歴メニュー()
                                case .ブックマーク: 📜ブックマークメニュー()
                                case .手駒増減(let 陣営): 🪄手駒増減メニュー(陣営)
                                case .SharePlayガイド: 👥SharePlayガイド()
                                case .広告: Text("🐛")
                            }
                        }
                        .toolbar { self.閉じるボタン() }
                    }
                    .environmentObject(📱)
                    .onAppear { 💥フィードバック.軽め() }
                }
            }
            .onAppear {
                if 🛒.checkToShowADSheet() { 📱.シートを表示 = .広告 }
            }
    }
    private func 閉じるボタン() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                📱.シートを表示 = nil
                💥フィードバック.軽め()
            } label: {
                Image(systemName: "chevron.down")
                    .grayscale(1.0)
            }
            .accessibilityLabel("Dismiss")
            .keyboardShortcut(.cancelAction)
        }
    }
}
