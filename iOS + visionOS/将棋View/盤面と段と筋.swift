import SwiftUI

struct 盤面と段と筋: View {
    @EnvironmentObject var モデル: アプリモデル
    var body: some View {
        if self.通常の向き {
            VStack(alignment: .leading, spacing: 0) {
                Self.筋()
                HStack(spacing: 0) { 盤面のみ(); Self.段() }
            }
        } else {
            VStack(alignment: .trailing, spacing: 0) {
                HStack(spacing: 0) { Self.段(); 盤面のみ() }
                Self.筋()
            }
        }
    }
}

private extension 盤面と段と筋 {
    private var 通常の向き: Bool {
        !モデル.上下反転
    }
    private struct 筋: View {
        @EnvironmentObject var モデル: アプリモデル
        @Environment(\.マスの大きさ) var マスの大きさ
        private static let 字 = ["９","８","７","６","５","４","３","２","１"]
        var body: some View {
            HStack(spacing: 0) {
                ForEach(モデル.上下反転 ? Self.字.reversed() : Self.字, id: \.self) {
                    駒テキスト(字: $0, 対象: .段筋)
                        .frame(width: self.マスの大きさ,
                               height: self.マスの大きさ * レイアウト.マスに対する段筋の大きさの比率)
                }
            }
        }
    }
    private struct 段: View {
        @EnvironmentObject var モデル: アプリモデル
        @Environment(\.マスの大きさ) var マスの大きさ
        private var 字: [String] {
            モデル.english表記 ? ["１","２","３","４","５","６","７","８","９"] : ["一","二","三","四","五","六","七","八","九"]
        }
        var body: some View {
            VStack(spacing: 0) {
                ForEach(モデル.上下反転 ? self.字.reversed() : self.字, id: \.self) {
                    駒テキスト(字: $0, 対象: .段筋)
                        .frame(width: self.マスの大きさ * レイアウト.マスに対する段筋の大きさの比率,
                               height: self.マスの大きさ)
                }
            }
        }
    }
}
