import SwiftUI

enum 🗄️固定値 {
    static var 枠線の太さ: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: return 1.0
            case .pad: return 1.33
            default: return 1.0
        }
    }
    static var 駒フォント: Font {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: return .title3
            case .pad: return .title
            default: return .title3
        }
    }
    static var 段筋フォント: Font {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: return .caption
            case .pad: return .body
            default: return .caption
        }
    }
}

struct 🗄️自動スリープオフ: ViewModifier {
    func body(content: Content) -> some View {
        content
            .task { UIApplication.shared.isIdleTimerDisabled = true }
    }
}

struct 🗄️初回起動時に駒の動かし方の説明バナー: ViewModifier {
    @AppStorage("起動回数") private var 起動回数: Int = 0
    @State private var 🚩駒操作説明バナーを表示: Bool = false
    func body(content: Content) -> some View {
        content
            .onAppear(perform: self.起動直後の確認作業)
            .overlay(alignment: .top) {
                if self.🚩駒操作説明バナーを表示 {
                    Label("長押しして駒を持ち上げ、そのままスライドして移動させる。", systemImage: "hand.point.up.left")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding()
                        .onTapGesture { self.🚩駒操作説明バナーを表示 = false }
                }
            }
            .animation(.default.speed(0.33), value: self.🚩駒操作説明バナーを表示)
    }
    private func 起動直後の確認作業() {
        self.起動回数 += 1
        if self.起動回数 == 1 {
            self.🚩駒操作説明バナーを表示 = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.🚩駒操作説明バナーを表示 = false
            }
        }
    }
}
