import SwiftUI

enum レイアウト {
    struct 推定: ViewModifier {
        func body(content: Content) -> some View {
            GeometryReader {
                content
                    .environment(\.マスの大きさ,
                                  $0.size.height / (9 + マスに対する段筋の大きさの比率))
            }
        }
    }
    static let マスに対する段筋の大きさの比率: Double = 0.5
    static let 複数個の盤外コマの幅比率: Double = 1.3
}
