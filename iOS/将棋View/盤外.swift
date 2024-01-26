import SwiftUI
import UniformTypeIdentifiers

struct 盤外: View {
    @EnvironmentObject var モデル: アプリモデル
    @Environment(\.マスの大きさ) var マスの大きさ
    @Environment(\.縦並び) var 縦並び
    private var 立場: 手前か対面か
    var body: some View {
        ZStack(alignment: self.揃え方) {
            Color(.systemBackground)
            Self.各種コマと増減ボタンの配置 {
                if self.立場 == .対面 { 手駒増減シート表示ボタン(self.陣営) }
                ForEach(self.各駒) { 盤外のコマ(self.陣営, $0) }
                if self.立場 == .手前 { 手駒増減シート表示ボタン(self.陣営) }
            }
        }
        .frame(maxWidth: self.最大の長さ, maxHeight: self.最大の長さ)
        .onTapGesture { モデル.こちらの手駒エリアを選択する(self.陣営) }
        .onDrop(of: [UTType.utf8PlainText],
                delegate: ドロップデリゲート(モデル, .盤外(self.陣営)))
    }
    init(_ ﾀﾁﾊﾞ: 手前か対面か) {
        self.立場 = ﾀﾁﾊﾞ
    }
}

private extension 盤外 {
    private var 陣営: 王側か玉側か {
        モデル.こちら側の陣営(self.立場)
    }
    private var 各駒: [駒の種類] {
        self.立場 == .手前 ? .Element.allCases : .Element.allCases.reversed()
    }
    private var 最大の長さ: CGFloat {
        self.マスの大きさ * (9 + レイアウト.マスに対する段筋の大きさの比率)
    }
    private var 揃え方: Alignment {
        switch (self.縦並び, self.立場) {
            case (true, .手前): .leading
            case (true, .対面): .trailing
            case (false, .手前): .bottom
            case (false, .対面): .top
        }
    }
    private struct 各種コマと増減ボタンの配置<Content: View>: View {
        @Environment(\.縦並び) var 縦並び
        @ViewBuilder var content: () -> Content
        var body: some View {
            if self.縦並び {
                HStack(spacing: 1.5) { self.content() }
                    .padding(.horizontal, 8)
            } else {
                VStack(spacing: 2) { self.content() }
                    .padding(.vertical, 8)
            }
        }
    }
}
