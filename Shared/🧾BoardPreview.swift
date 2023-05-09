import SwiftUI

struct 🧾局面プレビュー: View {
    @EnvironmentObject private var 📱: 📱アプリモデル
    private var 局面: 局面モデル
    private var マスのサイズ: CGFloat {
#if os(iOS)
        20
#elseif os(watchOS)
        9
#elseif os(tvOS)
        30
#else
        20
#endif
    }
    private var 盤面と手駒の隙間: CGFloat {
#if os(tvOS)
        12
#else
        3
#endif
    }
    var body: some View {
        VStack(spacing: self.盤面と手駒の隙間) {
            self.手駒プレビュー(.玉側)
            self.盤面プレビュー()
            self.手駒プレビュー(.王側)
        }
    }
    private func 盤面プレビュー() -> some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 9) { 行 in
                HStack(spacing: 0) {
                    ForEach(0 ..< 9) { 列 in
                        let 位置 = 行 * 9 + 列
                        if let 駒 = self.局面.盤駒[位置] {
                            Text(🔠文字.装飾(self.局面.この駒の表記(.盤駒(位置), 📱.🚩English表記) ?? "🐛",
                                         フォント: .system(size: self.マスのサイズ,
                                                       weight: self.局面.直近の操作 == .盤駒(位置) ? .bold : .light),
                                         下線: self.局面.この駒にはアンダーラインが必要(.盤駒(位置), 📱.🚩English表記)))
                            .rotationEffect(駒.陣営 == .玉側 ? .degrees(180) : .zero)
                            .minimumScaleFactor(0.1)
                            .frame(width: self.マスのサイズ, height: self.マスのサイズ)
                        } else {
                            Color.clear
                                .frame(width: self.マスのサイズ, height: self.マスのサイズ)
                        }
                    }
                }
            }
        }
        .frame(width: self.マスのサイズ * 9, height: self.マスのサイズ * 9)
        .padding(2)
        .border(.primary, width: 0.66)
    }
    private func 手駒プレビュー(_ 陣営: 王側か玉側か) -> some View {
        HStack(spacing: 2) {
            ForEach(駒の種類.allCases) {
                if let 表記 = self.局面.この駒の表記(.手駒(陣営, $0), 📱.🚩English表記) {
                    Text(🔠文字.装飾(表記, フォント: .system(size: self.マスのサイズ, weight: .light)))
                        .minimumScaleFactor(0.1)
                }
            }
        }
        .rotationEffect(陣営 == .玉側 ? .degrees(180) : .zero)
        .frame(width: self.マスのサイズ * 9, height: self.マスのサイズ)
    }
    init(_ 局面: 局面モデル) { self.局面 = 局面 }
}
