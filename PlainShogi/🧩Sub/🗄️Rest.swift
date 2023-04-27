import SwiftUI

enum 🗄️固定値 {
    static var 枠線の太さ: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: return 1.0
            case .pad:
#if targetEnvironment(macCatalyst)
                return 2
#else
                return 1.33
#endif
            case .tv: return 2
            default: return 1.0
        }
    }
    static var 全体パディング: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: return 16
            case .pad:
#if targetEnvironment(macCatalyst)
                return 32
#else
                return 24
#endif
            case .tv: return 36
            default: return 16
        }
    }
}

struct 🗄️自動スリープ無効化: ViewModifier {
    func body(content: Content) -> some View {
        content
            .task { UIApplication.shared.isIdleTimerDisabled = true }
    }
}

struct 🗄️初回起動時に駒の動かし方の説明バナー: ViewModifier {
    @AppStorage("起動回数") private var 起動回数: Int = 0
    @State private var 🚩バナーを表示: Bool = false
    func body(content: Content) -> some View {
        content
            .onAppear(perform: self.起動直後の確認作業)
            .overlay(alignment: .top) {
                if self.🚩バナーを表示 {
                    Label("長押しして駒を持ち上げ、そのままスライドして移動させる。", systemImage: "hand.point.up.left")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding()
                        .onTapGesture { self.🚩バナーを表示 = false }
                }
            }
            .animation(.default.speed(0.33), value: self.🚩バナーを表示)
    }
    private func 起動直後の確認作業() {
        self.起動回数 += 1
        if self.起動回数 == 1 {
            self.🚩バナーを表示 = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.🚩バナーを表示 = false
            }
        }
    }
}
