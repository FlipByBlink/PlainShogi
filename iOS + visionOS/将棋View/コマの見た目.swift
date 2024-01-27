import SwiftUI

struct コマの見た目: View { //FrameやDrag処理などは呼び出し側で実装する
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    private var 場所: 駒の場所
    var body: some View {
        if let 表記 {
            ZStack {
                Color(.systemBackground)
                駒テキスト(字: 表記,
                      強調: self.この駒は操作直後,
                      下線: モデル.この駒にはアンダーラインが必要(self.場所))
                .rotationEffect(モデル.この駒は下向き(self.場所) ? .degrees(180) : .zero)
                .rotationEffect(.degrees(モデル.増減モード中 ? 15 : 0))
                .onChange(of: モデル.増減モード中) { _ in モデル.駒の選択を解除する() }
            }
            .modifier(Self.駒選択効果(self.場所))
            .modifier(増減モード用ⓧマーク(self.場所))
            .modifier(Self.ドラッグ直後の効果(self.場所))
            .modifier(Self.太字設定時の駒操作後効果(self.場所))
        }
    }
    init(_ ﾊﾞｼｮ: 駒の場所) {
        self.場所 = ﾊﾞｼｮ
    }
}

private extension コマの見た目 {
    private var 表記: String? {
        モデル.この駒の表記(self.場所)
    }
    private var この駒は操作直後: Bool {
        モデル.この駒は操作直後なので強調表示(self.場所)
    }
    private struct ドラッグ直後の効果: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        private var 場所: 駒の場所
        @State private var ドラッグした直後: Bool = false
        func body(content: Content) -> some View {
            content
                .opacity(self.ドラッグした直後 ? 0.25 : 1.0)
                .onChange(of: モデル.ドラッグ中の駒) {
                    if case .アプリ内の駒(let 出発地点) = $0, 出発地点 == self.場所 {
                        self.ドラッグした直後 = true
                        withAnimation(.easeIn(duration: 1.25).delay(1)) {
                            self.ドラッグした直後 = false
                        }
                    }
                }
        }
        init(_ ﾊﾞｼｮ: 駒の場所) { 
            self.場所 = ﾊﾞｼｮ
        }
    }
    private struct 駒選択効果: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        private var 場所: 駒の場所
        private var 条件: Bool { モデル.選択中の駒 == self.場所 }
        func body(content: Content) -> some View {
#if os(iOS)
            content
                .border(.tint, width: self.条件 ? 固定値.強調枠線の太さ : 0)
                .animation(.default.speed(2), value: self.条件)
#elseif os(visionOS)
            content
                .background { Rectangle().fill(.quaternary).opacity(self.条件 ? 1 : 0) }
                .modifier(VisionOS向けHoverEffect.コマ())
                .offset(z: self.条件 ? 30 : 0)
                .scaleEffect(self.条件 ? 1.15 : 1)
                .animation(.default.speed(2), value: self.条件)
#endif
        }
        init(_ ﾊﾞｼｮ: 駒の場所) {
            self.場所 = ﾊﾞｼｮ
        }
    }
    private struct 太字設定時の駒操作後効果: ViewModifier {
        @EnvironmentObject var モデル: アプリモデル
        private var 場所: 駒の場所
        private var 条件: Bool { モデル.太字 && モデル.この駒は操作直後なので強調表示(self.場所) }
        func body(content: Content) -> some View {
            content
                .overlay {
#if os(iOS)
                    if self.条件 {
                        Rectangle().fill(.quaternary)
                    }
#elseif os(visionOS)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke()
                        .opacity(self.条件 ? 1 : 0)
#endif
                }
        }
        init(_ ﾊﾞｼｮ: 駒の場所) {
            self.場所 = ﾊﾞｼｮ
        }
    }
}
