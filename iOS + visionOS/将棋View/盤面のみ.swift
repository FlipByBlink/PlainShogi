import SwiftUI

struct 盤面のみ: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    @Environment(\.画像書き出し) var 画像書き出し
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 9) { 行 in
                if 行 != 0 { Self.仕切り線() }
                HStack(spacing: 0) {
                    ForEach(0 ..< 9) { 列 in
                        if 列 != 0 { Self.仕切り線() }
                        盤面のコマもしくはマス(行 * 9 + 列)
                    }
                }
            }
        }
        .overlay { self.枠線() }
        .frame(width: self.マスの大きさ * 9,
               height: self.マスの大きさ * 9)
    }
}

private extension 盤面のみ {
    private var 枠線の太さ: CGFloat {
        switch self.マスの大きさ {
            case ..<50: 1
            case 50..<100: 1.5
            case 100...: 2
            default: 1
        }
    }
    private func 枠線() -> some View {
#if os(iOS)
        Rectangle()
            .stroke(.primary, lineWidth: self.枠線の太さ)
#elseif os(visionOS)
        RoundedRectangle(cornerRadius: self.画像書き出し ? 0 : 8,
                         style: .continuous)
        .stroke(.primary, lineWidth: self.枠線の太さ)
#endif
    }
    private static func 仕切り線() -> some View {
        Divider()
            .modifier(Self.VisionOS用画像書き出し用Dividerエフェクト())
    }
    private struct VisionOS用画像書き出し用Dividerエフェクト: ViewModifier {
        @Environment(\.画像書き出し) var 画像書き出し
        func body(content: Content) -> some View {
#if os(visionOS)
            if self.画像書き出し {
                content.colorMultiply(.black)
            } else {
                content
            }
#else
            content
#endif
        }
    }
}
