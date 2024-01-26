import SwiftUI

struct 盤面のみ: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< 9) { 行 in
                if 行 != 0 { Divider() }
                HStack(spacing: 0) {
                    ForEach(0 ..< 9) { 列 in
                        if 列 != 0 { Divider() }
                        盤面のコマもしくはマス(行 * 9 + 列)
                    }
                }
            }
        }
        .border(.primary, width: self.枠線の太さ)
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
}
