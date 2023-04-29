import SwiftUI

struct 🪧シート: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    func body(content: Content) -> some View {
        content
            .sheet(item: $📱.シートを表示) { カテゴリ in
                NavigationView {
                    Group {
                        switch カテゴリ {
                            case .メニュー: 🛠アプリメニュー()
                            case .履歴: 📜履歴メニュー()
                            case .ブックマーク: 📜ブックマークメニュー()
                            case .手駒編集(let 陣営): 🪄手駒編集メニュー(陣営)
                            case .SharePlayガイド: 👥SharePlayガイド()
                        }
                    }
                    .toolbar { self.閉じるボタン() }
                }
                .environmentObject(📱)
                .onAppear { 💥フィードバック.軽め() }
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
        }
    }
}

enum シートカテゴリ: Identifiable, Hashable {
    case メニュー, 履歴, ブックマーク, 手駒編集(王側か玉側か), SharePlayガイド
    var id: Self { self }
}
