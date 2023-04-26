import SwiftUI

typealias 🛒Storeモデル = 🛒StoreModel

struct 🗄️太字システムオプション用の強調表示: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    @Environment(\.legibilityWeight) private var legibilityWeight
    private let 場所: 駒の場所
    func body(content: Content) -> some View {
        content
            .overlay {
                if 📱.この駒は操作直後なので強調表示(self.場所), self.legibilityWeight == .bold {
                    Rectangle()
                        .fill(.quaternary)
                }
            }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
}

struct 🗄️ドラッグ直後の効果: ViewModifier {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 場所: 駒の場所
    @State private var ドラッグした直後: Bool = false
    func body(content: Content) -> some View {
        content
            .opacity(self.ドラッグした直後 ? 0.25 : 1.0)
            .onChange(of: 📱.ドラッグ中の駒) {
                if case .アプリ内の駒(let 出発地点) = $0, 出発地点 == self.場所 {
                    self.ドラッグした直後 = true
                    withAnimation(.easeIn(duration: 1.25).delay(1)) {
                        self.ドラッグした直後 = false
                    }
                }
            }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) { self.場所 = ﾊﾞｼｮ }
}

enum 🗄️固定値 {
    static var 枠線の太さ: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .phone: return 1.0
            case .pad: return 1.33
            default: return 1.0
        }
    }
}

enum 🗄️フォント {
    static func 駒(_ セリフ体: Bool) -> Font {
        var スタイル: Font.TextStyle {
            switch UIDevice.current.userInterfaceIdiom {
                case .phone: return .title3
                case .pad: return .title
                default: return .title3
            }
        }
        return .system(スタイル, design: セリフ体 ? .serif : .default)
    }
    static func 段と筋(_ セリフ体: Bool) -> Font {
        var スタイル: Font.TextStyle {
            switch UIDevice.current.userInterfaceIdiom {
                case .phone: return .caption
                case .pad: return .body
                default: return .caption
            }
        }
        return .system(スタイル, design: セリフ体 ? .serif : .default)
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
