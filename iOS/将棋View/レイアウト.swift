import SwiftUI

enum レイアウト {
    struct 推定: ViewModifier {
        func body(content: Content) -> some View {
            GeometryReader {
                let 計算結果 = レイアウト.配置とマスの大きさを計算($0)
                content
                    .environment(\.マスの大きさ, 計算結果.マスの大きさ)
                    .environment(\.縦並び, 計算結果.縦並び)
            }
        }
    }
    private static func 配置とマスの大きさを計算(_ ジオメトリ: GeometryProxy) -> (縦並び: Bool, マスの大きさ: CGFloat) {
        let 縦並び = ジオメトリ.size.height + 150 > ジオメトリ.size.width
        let 横換算 = 一辺を基準にした際の計算式(全体の長さ: ジオメトリ.size.width,
                                盤外コマの比率: 縦並び ? 0 : Self.複数個の盤外コマの幅比率 * 2)
        let 縦換算 = 一辺を基準にした際の計算式(全体の長さ: ジオメトリ.size.height,
                                盤外コマの比率: 縦並び ? 2 : 0)
        return (縦並び, min(横換算, 縦換算))
        func 一辺を基準にした際の計算式(全体の長さ: CGFloat, 盤外コマの比率: Double) -> CGFloat {
            (全体の長さ - Self.盤と手駒の隙間 * 2)
            /
            (9 + Self.マスに対する段筋の大きさの比率 + 盤外コマの比率)
        }
    }
    static let 盤と手駒の隙間: CGFloat = 4
    static let マスに対する段筋の大きさの比率: Double = 0.5
    static let 複数個の盤外コマの幅比率: Double = 1.3
}
